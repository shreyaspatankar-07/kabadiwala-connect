/**
 * useLotFeed — real-time lot updates via WebSocket with polling fallback.
 *
 * Behaviour:
 * 1. On mount: loads existing lots via REST GET /lots (catch-up).
 * 2. Opens ws://…/ws/recycler?recycler_id=<id> for push updates.
 * 3. On "lot.created" message: prepends the new lot without a full refresh.
 * 4. On socket drop: reconnects with exponential backoff (1 s → 2 s → 4 s … 30 s cap).
 * 5. While the socket is disconnected: polls GET /lots?since=<lastSeen> every 5 s
 *    so no lot is missed during a gap.
 */

import { useCallback, useEffect, useRef, useState } from "react";
import { fetchLiveLots } from "../lib/api";
import { MatchedLot } from "../lib/types";

const API_BASE =
  process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000/api/v1";
const WS_BASE = API_BASE.replace(/^http/, "ws").replace("/api/v1", "");

interface UseLotFeedOptions {
  recycler_id: string;
  /** Initial lots to display before the first fetch resolves. */
  initialLots?: MatchedLot[];
  pollIntervalMs?: number;
}

interface UseLotFeedResult {
  lots: MatchedLot[];
  isConnected: boolean;
  connectionStatus: "connecting" | "connected" | "polling" | "offline";
  refresh: () => Promise<void>;
}

export function useLotFeed({
  recycler_id,
  initialLots = [],
  pollIntervalMs = 5000,
}: UseLotFeedOptions): UseLotFeedResult {
  const [lots, setLots] = useState<MatchedLot[]>(initialLots);
  const [connectionStatus, setConnectionStatus] = useState<
    "connecting" | "connected" | "polling" | "offline"
  >("connecting");

  const wsRef = useRef<WebSocket | null>(null);
  const backoffRef = useRef(1000); // ms
  const pollRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const lastSeenRef = useRef<string>(new Date(0).toISOString());
  const mountedRef = useRef(true);

  // ── REST catch-up ────────────────────────────────────────────────────────
  const refresh = useCallback(async () => {
    const live = await fetchLiveLots();
    if (!mountedRef.current) return;
    if (live.length > 0) {
      setLots(live);
      lastSeenRef.current = new Date().toISOString();
    }
  }, []);

  // ── Polling fallback (runs when socket is down) ───────────────────────────
  const startPolling = useCallback(() => {
    if (pollRef.current) return; // already polling
    setConnectionStatus("polling");
    pollRef.current = setInterval(async () => {
      const live = await fetchLiveLots();
      if (!mountedRef.current) return;
      if (live.length > 0) {
        setLots(live);
        lastSeenRef.current = new Date().toISOString();
      }
    }, pollIntervalMs);
  }, [pollIntervalMs]);

  const stopPolling = useCallback(() => {
    if (pollRef.current) {
      clearInterval(pollRef.current);
      pollRef.current = null;
    }
  }, []);

  // ── WebSocket connection ──────────────────────────────────────────────────
  const connect = useCallback(() => {
    if (!mountedRef.current) return;

    const url = `${WS_BASE}/ws/recycler?recycler_id=${encodeURIComponent(recycler_id)}`;
    setConnectionStatus("connecting");
    console.log("[useLotFeed] Connecting WebSocket →", url);

    let ws: WebSocket;
    try {
      ws = new WebSocket(url);
    } catch (e) {
      console.warn("[useLotFeed] WebSocket construction failed:", e);
      startPolling();
      return;
    }

    wsRef.current = ws;

    // Keep-alive ping every 25 s
    let pingInterval: ReturnType<typeof setInterval> | null = null;

    ws.onopen = () => {
      if (!mountedRef.current) return;
      console.log("[useLotFeed] WebSocket connected");
      backoffRef.current = 1000; // reset backoff on successful connect
      setConnectionStatus("connected");
      stopPolling(); // stop REST poll now that socket is live
      pingInterval = setInterval(() => {
        if (ws.readyState === WebSocket.OPEN) ws.send("ping");
      }, 25000);
    };

    ws.onmessage = (event) => {
      if (!mountedRef.current) return;
      try {
        const msg = JSON.parse(event.data);
        if (msg.type === "lot.created" && msg.lot) {
          const raw = msg.lot;
          // Map the backend lot shape to the portal MatchedLot type
          const newLot: MatchedLot = {
            id: raw.lot_id,
            lotId: raw.lot_id,
            clientLotUuid: raw.lot_id,
            collectorRefId: "KC-C-???", // not sent in broadcast (privacy)
            category: raw.category ?? "Other",
            subCategory: raw.category,
            condition: "broken",
            weightKg: Number(raw.weight_kg) || 1,
            estimatedValue: Number(raw.quoted_price) || 0,
            distanceKm: 0,
            quotedPrice: Number(raw.quoted_price) || 0,
            pickupRequested: true,
            photoUrl: "",
            photoHash: "",
            createdAt: raw.created_at ?? new Date().toISOString(),
            status: "matched",
            handoverRefNo: "",
          };
          // Prepend — newest lot first
          setLots((prev) => {
            if (prev.some((l) => l.lotId === newLot.lotId)) return prev;
            return [newLot, ...prev];
          });
          lastSeenRef.current = new Date().toISOString();
          console.log("[useLotFeed] lot.created received:", raw.lot_id);
        }
      } catch (e) {
        console.warn("[useLotFeed] Failed to parse WS message:", e);
      }
    };

    ws.onerror = (e) => {
      console.warn("[useLotFeed] WebSocket error:", e);
    };

    ws.onclose = (e) => {
      if (pingInterval) clearInterval(pingInterval);
      wsRef.current = null;
      if (!mountedRef.current) return;

      console.warn(
        `[useLotFeed] WebSocket closed code=${e.code} reason="${e.reason}" — reconnecting in ${backoffRef.current}ms`
      );
      // Start polling to bridge the gap while we're disconnected
      startPolling();

      // Exponential backoff capped at 30 s
      const delay = backoffRef.current;
      backoffRef.current = Math.min(backoffRef.current * 2, 30000);
      setTimeout(() => {
        if (mountedRef.current) connect();
      }, delay);
    };
  }, [recycler_id, startPolling, stopPolling]); // eslint-disable-line react-hooks/exhaustive-deps

  // ── Mount / unmount ───────────────────────────────────────────────────────
  useEffect(() => {
    mountedRef.current = true;
    // Initial REST fetch so the page isn't empty while socket handshakes
    refresh();
    connect();

    return () => {
      mountedRef.current = false;
      stopPolling();
      if (wsRef.current) {
        wsRef.current.onclose = null; // prevent reconnect loop on unmount
        wsRef.current.close(1000, "component unmounted");
      }
    };
  }, [connect, refresh, stopPolling]);

  return {
    lots,
    isConnected: connectionStatus === "connected",
    connectionStatus,
    refresh,
  };
}
