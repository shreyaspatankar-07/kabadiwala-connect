/* eslint-disable @next/next/no-img-element */
"use client";

import React, { useState, useCallback } from "react";
import { useLanguage } from "../../context/LanguageContext";
import { mockMatchedLots, updateLotStatusApi } from "../../lib/api";
import { useLotFeed } from "../../lib/useLotFeed";
import { MatchedLot } from "../../lib/types";
import {
  CheckCircle2,
  XCircle,
  MessageSquare,
  MapPin,
  Scale,
  IndianRupee,
  Truck,
  ShieldCheck,
  RefreshCw,
  Radio,
} from "lucide-react";

export function MatchedLotsInboxView() {
  const { t } = useLanguage();
  const [counterModalLot, setCounterModalLot] = useState<MatchedLot | null>(null);
  const [counterRate, setCounterRate] = useState<string>("");
  const [actionSuccessMessage, setActionSuccessMessage] = useState<string | null>(null);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [lastUpdatedTime, setLastUpdatedTime] = useState<string>("Just now");

  // Real-time lot feed: WebSocket primary, REST polling fallback on disconnect.
  // Falls back to mockMatchedLots as initialLots so the UI is never empty.
  const {
    lots,
    connectionStatus,
    isConnected,
    refresh: feedRefresh,
  } = useLotFeed({
    recycler_id: "REC-ECO-01", // TODO: replace with auth context recycler_id
    initialLots: mockMatchedLots,
  });

  const refreshLots = useCallback(async () => {
    setIsRefreshing(true);
    await feedRefresh();
    setLastUpdatedTime(new Date().toLocaleTimeString());
    setIsRefreshing(false);
  }, [feedRefresh]);

  // Optimistic local overrides for accept / decline / counter — merged at render
  const [localOverrides, setLocalOverrides] = useState<Record<string, Partial<MatchedLot>>>({});
  const displayLots = lots.map((l) => ({ ...l, ...(localOverrides[l.lotId] ?? {}) }));

  const handleAccept = async (lotId: string) => {
    setLocalOverrides((prev) => ({ ...prev, [lotId]: { status: "accepted" } }));
    await updateLotStatusApi(lotId, "accepted");
    setActionSuccessMessage(`Lot ${lotId} accepted! Handover code generated for collector.`);
    setTimeout(() => setActionSuccessMessage(null), 4000);
  };

  const handleDecline = async (lotId: string) => {
    setLocalOverrides((prev) => ({ ...prev, [lotId]: { status: "declined" } }));
    await updateLotStatusApi(lotId, "cancelled");
    setActionSuccessMessage(`Lot ${lotId} declined.`);
    setTimeout(() => setActionSuccessMessage(null), 4000);
  };

  const handleOpenCounter = (lot: MatchedLot) => {
    setCounterModalLot(lot);
    setCounterRate(Math.round(lot.quotedPrice / lot.weightKg).toString());
  };

  const submitCounterOffer = async () => {
    if (!counterModalLot) return;
    const rate = parseFloat(counterRate) || 0;
    const newPrice = rate * counterModalLot.weightKg;
    setLocalOverrides((prev) => ({
      ...prev,
      [counterModalLot.lotId]: { status: "counter_offered" as any, quotedPrice: newPrice },
    }));
    await updateLotStatusApi(counterModalLot.lotId, "matched", newPrice);
    setActionSuccessMessage(
      `Counter-offer of ₹${rate}/kg sent to collector for Lot ${counterModalLot.lotId}`
    );
    setCounterModalLot(null);
    setTimeout(() => setActionSuccessMessage(null), 4000);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-3">
            <h1 className="text-2xl font-extrabold text-white">{t.navInbox}</h1>
            {isConnected ? (
              <span className="flex items-center gap-1.5 px-2.5 py-1 bg-emerald-500/10 border border-emerald-500/30 text-emerald-400 rounded-full text-xs font-semibold animate-pulse">
                <Radio className="w-3.5 h-3.5 text-emerald-400" />
                Live · WebSocket
              </span>
            ) : connectionStatus === "polling" ? (
              <span className="flex items-center gap-1.5 px-2.5 py-1 bg-amber-500/10 border border-amber-500/30 text-amber-400 rounded-full text-xs font-semibold">
                <Radio className="w-3.5 h-3.5 text-amber-400" />
                Polling (reconnecting…)
              </span>
            ) : (
              <span className="flex items-center gap-1.5 px-2.5 py-1 bg-slate-700/40 border border-slate-600/30 text-slate-400 rounded-full text-xs font-semibold">
                <Radio className="w-3.5 h-3.5" />
                Connecting…
              </span>
            )}
          </div>
          <p className="text-xs text-slate-400 mt-1">
            Incoming matched e-waste lots from nearby informal collectors • Updated {lastUpdatedTime}
          </p>
        </div>
        <div className="flex items-center space-x-3">
          <button
            onClick={refreshLots}
            disabled={isRefreshing}
            className="flex items-center gap-1.5 px-3 py-1.5 bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 rounded-lg text-xs font-bold transition shadow-sm"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${isRefreshing ? "animate-spin text-emerald-400" : ""}`} />
            Refresh Feed
          </button>
          <span className="px-3 py-1.5 bg-emerald-950 text-emerald-300 border border-emerald-800 rounded-lg text-xs font-bold">
            {lots.filter((l) => l.status === "matched").length} Pending Actions
          </span>
        </div>
      </div>

      {/* Success Banner */}
      {actionSuccessMessage && (
        <div className="bg-emerald-950/90 border border-emerald-600 text-emerald-200 px-4 py-3 rounded-xl flex items-center space-x-2 text-sm font-semibold animate-fade-in">
          <CheckCircle2 className="w-5 h-5 text-emerald-400" />
          <span>{actionSuccessMessage}</span>
        </div>
      )}

      {/* Matched Lots Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {displayLots.map((lot) => {
          const ratePerKg = (lot.quotedPrice / lot.weightKg).toFixed(0);
          const isPending = lot.status === "matched";

          return (
            <div
              key={lot.id}
              data-testid={`lot-card-${lot.id}`}
              className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden shadow-xl flex flex-col justify-between hover:border-slate-700 transition"
            >
              <div>
                {/* Photo Header with Badge Overlay */}
                <div className="relative h-44 bg-slate-950 overflow-hidden">
                  <img
                    src={lot.photoUrl}
                    alt={lot.category}
                    className="w-full h-full object-cover opacity-90 hover:scale-105 transition duration-500"
                  />
                  <div className="absolute top-3 left-3 flex gap-2">
                    <span className="bg-slate-900/90 backdrop-blur text-white text-xs font-black px-2.5 py-1 rounded-lg border border-slate-700">
                      {lot.category}
                    </span>
                    <span className="bg-emerald-600 text-white text-xs font-bold px-2 py-1 rounded-lg shadow">
                      {lot.subCategory || "Standard"}
                    </span>
                  </div>
                  <div className="absolute top-3 right-3">
                    <span
                      className={`text-xs font-bold px-2.5 py-1 rounded-lg border uppercase tracking-wider ${
                        lot.status === "accepted"
                          ? "bg-emerald-950 text-emerald-300 border-emerald-700"
                          : lot.status === "counter_offered"
                          ? "bg-blue-950 text-blue-300 border-blue-700"
                          : lot.status === "declined"
                          ? "bg-red-950 text-red-300 border-red-700"
                          : "bg-amber-950 text-amber-300 border-amber-700"
                      }`}
                    >
                      {lot.status}
                    </span>
                  </div>
                  <div className="absolute bottom-2 left-3 right-3 flex justify-between items-center text-[11px] bg-slate-950/80 backdrop-blur px-2.5 py-1 rounded-md text-slate-300 font-mono">
                    <span>ID: {lot.lotId}</span>
                    <span>Col: {lot.collectorRefId}</span>
                  </div>
                </div>

                {/* Key Metrics */}
                <div className="p-5 space-y-4">
                  <div className="grid grid-cols-3 gap-2 text-center bg-slate-800/80 rounded-xl p-3 border border-slate-700/80">
                    <div>
                      <span className="text-[10px] text-slate-400 font-bold block">WEIGHT</span>
                      <span className="text-base font-black text-white flex items-center justify-center gap-0.5">
                        <Scale className="w-3.5 h-3.5 text-emerald-400" />
                        {lot.weightKg} kg
                      </span>
                    </div>
                    <div>
                      <span className="text-[10px] text-slate-400 font-bold block">DISTANCE</span>
                      <span className="text-base font-black text-white flex items-center justify-center gap-0.5">
                        <MapPin className="w-3.5 h-3.5 text-blue-400" />
                        {lot.distanceKm} km
                      </span>
                    </div>
                    <div>
                      <span className="text-[10px] text-slate-400 font-bold block">RATE</span>
                      <span className="text-base font-black text-emerald-400">
                        ₹{ratePerKg}/kg
                      </span>
                    </div>
                  </div>

                  {/* Financial Total */}
                  <div className="flex justify-between items-center px-1">
                    <div>
                      <span className="text-xs text-slate-400 block">Total Est. Value</span>
                      <span className="text-2xl font-extrabold text-emerald-400 flex items-center">
                        <IndianRupee className="w-5 h-5" />
                        {lot.quotedPrice.toLocaleString()}
                      </span>
                    </div>
                    {lot.pickupRequested && (
                      <span className="flex items-center space-x-1 text-xs font-bold text-blue-300 bg-blue-950/90 px-2.5 py-1 rounded-lg border border-blue-800">
                        <Truck className="w-3.5 h-3.5" />
                        <span>Pickup</span>
                      </span>
                    )}
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="p-5 pt-0">
                {isPending ? (
                  <div className="grid grid-cols-3 gap-2">
                    <button
                      onClick={() => handleAccept(lot.id)}
                      data-testid={`btn-accept-${lot.id}`}
                      className="bg-emerald-600 hover:bg-emerald-500 text-white font-bold py-2 px-3 rounded-xl text-xs flex items-center justify-center space-x-1 shadow-lg shadow-emerald-900/40 transition"
                    >
                      <CheckCircle2 className="w-3.5 h-3.5" />
                      <span>{t.btnAccept}</span>
                    </button>
                    <button
                      onClick={() => handleOpenCounter(lot)}
                      data-testid={`btn-counter-${lot.id}`}
                      className="bg-slate-800 hover:bg-slate-700 text-amber-300 border border-amber-500/40 font-bold py-2 px-2 rounded-xl text-xs flex items-center justify-center space-x-1 transition"
                    >
                      <MessageSquare className="w-3.5 h-3.5" />
                      <span>Counter</span>
                    </button>
                    <button
                      onClick={() => handleDecline(lot.id)}
                      data-testid={`btn-decline-${lot.id}`}
                      className="bg-slate-800 hover:bg-red-950 hover:text-red-300 text-slate-400 font-bold py-2 px-2 rounded-xl text-xs flex items-center justify-center space-x-1 transition"
                    >
                      <XCircle className="w-3.5 h-3.5" />
                      <span>Decline</span>
                    </button>
                  </div>
                ) : (
                  <div className="text-center py-2 bg-slate-800/60 rounded-xl text-xs font-semibold text-slate-400">
                    Handover code:{" "}
                    <span className="font-mono text-emerald-400 font-bold">
                      {lot.handoverRefNo || "H6-GEN2"}
                    </span>
                  </div>
                )}
              </div>
            </div>
          );
        })}
      </div>

      {/* Counter-Offer Modal */}
      {counterModalLot && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-slate-900 border border-slate-700 rounded-2xl max-w-md w-full p-6 space-y-4 shadow-2xl">
            <h3 className="text-lg font-extrabold text-white">
              Propose Counter-Offer: {counterModalLot.lotId}
            </h3>
            <p className="text-xs text-slate-400">
              Collector estimated ₹{(counterModalLot.quotedPrice / counterModalLot.weightKg).toFixed(0)}/kg for {counterModalLot.weightKg} kg {counterModalLot.category}.
            </p>
            <div className="space-y-2">
              <label className="text-xs font-bold text-slate-300">
                New Offered Rate (₹ / kg)
              </label>
              <div className="relative">
                <IndianRupee className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
                <input
                  type="number"
                  value={counterRate}
                  onChange={(e) => setCounterRate(e.target.value)}
                  className="w-full bg-slate-800 border border-slate-700 rounded-xl pl-9 pr-4 py-2.5 text-white font-bold focus:outline-none focus:border-emerald-500"
                />
              </div>
            </div>
            <div className="bg-slate-800/80 p-3 rounded-xl text-xs space-y-1">
              <div className="flex justify-between text-slate-400">
                <span>Total New Payout:</span>
                <span className="font-extrabold text-emerald-400">
                  ₹{((parseFloat(counterRate) || 0) * counterModalLot.weightKg).toLocaleString()}
                </span>
              </div>
            </div>
            <div className="flex justify-end space-x-3 pt-2">
              <button
                onClick={() => setCounterModalLot(null)}
                className="px-4 py-2 rounded-xl text-xs font-bold text-slate-300 hover:bg-slate-800"
              >
                Cancel
              </button>
              <button
                onClick={submitCounterOffer}
                data-testid="submit-counter-offer"
                className="px-5 py-2 rounded-xl text-xs font-bold bg-emerald-600 hover:bg-emerald-500 text-white shadow"
              >
                Send Counter-Offer
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
