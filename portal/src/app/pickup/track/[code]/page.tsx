"use client";

import React, { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import {
  CheckCircle2,
  Clock,
  Truck,
  MapPin,
  RefreshCw,
  Home,
  ShieldCheck,
  PhoneCall,
  Recycle,
  Sparkles,
} from "lucide-react";
import { trackPickupRequest, CitizenPickupStatus } from "@/lib/api";

const STEPS = [
  { id: "CREATED", label: "Request Posted", desc: "Broadcasted to nearby collectors" },
  { id: "ACCEPTED", label: "Collector Assigned", desc: "A verified kabadiwala accepted" },
  { id: "ARRIVED", label: "At Doorstep", desc: "Collector arrived for valuation" },
  { id: "COMPLETED", label: "Completed", desc: "Material collected & cash paid" },
];

export default function TrackPickupPage() {
  const router = useRouter();
  const rawParams = useParams();
  const code = (rawParams?.code as string) || "";

  const [statusData, setStatusData] = useState<CitizenPickupStatus | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [refreshing, setRefreshing] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const fetchStatus = async (showSpin = false) => {
    if (!code) return;
    if (showSpin) setRefreshing(true);
    try {
      const data = await trackPickupRequest(code);
      setStatusData(data);
      setError(null);
    } catch (err: any) {
      setError(err.message || "Failed to load pickup status");
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchStatus();
    // Poll every 5 seconds for live state machine updates
    const interval = setInterval(() => {
      fetchStatus();
    }, 5000);
    return () => clearInterval(interval);
  }, [code]);

  const getStepIndex = (statusStr: string) => {
    switch (statusStr?.toUpperCase()) {
      case "CREATED":
      case "DISPATCHED":
        return 0;
      case "ACCEPTED":
        return 1;
      case "ARRIVED":
        return 2;
      case "COMPLETED":
        return 3;
      default:
        return 0;
    }
  };

  const currentStepIdx = getStepIndex(statusData?.status || "CREATED");

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 flex flex-col justify-between">
      {/* Header */}
      <header className="border-b border-slate-800 bg-slate-900/90 backdrop-blur sticky top-0 z-40 px-4 py-3.5">
        <div className="max-w-3xl mx-auto flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-9 h-9 rounded-xl bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-emerald-400 font-bold">
              <Recycle className="w-5 h-5 text-emerald-400" />
            </div>
            <div>
              <span className="font-bold text-white text-base">Pickup Tracker</span>
              <p className="text-xs text-slate-400">Live Status & Collector Dispatch</p>
            </div>
          </div>
          <button
            onClick={() => router.push("/pickup")}
            className="flex items-center gap-1.5 text-xs text-slate-300 hover:text-white bg-slate-800 border border-slate-700 px-3 py-1.5 rounded-lg transition"
          >
            <Home className="w-3.5 h-3.5" /> Book New
          </button>
        </div>
      </header>

      {/* Main Container */}
      <main className="max-w-2xl mx-auto w-full px-4 py-8 flex-1">
        {/* Status Card */}
        <div className="bg-slate-800/60 border border-slate-700/80 rounded-2xl p-6 shadow-xl mb-6">
          <div className="flex items-start justify-between border-b border-slate-700/60 pb-4 mb-6">
            <div>
              <span className="text-[11px] font-mono uppercase tracking-wider text-emerald-400 block mb-1">
                Tracking Reference
              </span>
              <div className="text-2xl font-mono font-bold text-white tracking-wide">{code}</div>
            </div>
            <button
              onClick={() => fetchStatus(true)}
              disabled={refreshing}
              className="flex items-center gap-1.5 text-xs text-slate-400 hover:text-emerald-400 p-2 rounded-lg bg-slate-900/60 border border-slate-700 transition"
              title="Refresh status"
            >
              <RefreshCw className={`w-3.5 h-3.5 ${refreshing ? "animate-spin text-emerald-400" : ""}`} />
            </button>
          </div>

          {/* Stepper Timeline */}
          <div className="space-y-6 mb-8">
            {STEPS.map((step, idx) => {
              const isPast = idx < currentStepIdx;
              const isCurrent = idx === currentStepIdx;
              const isFuture = idx > currentStepIdx;

              return (
                <div key={step.id} className="flex items-start gap-4 relative">
                  {/* Connecting Line */}
                  {idx !== STEPS.length - 1 && (
                    <div
                      className={`absolute left-[17px] top-[34px] w-0.5 h-[calc(100%+8px)] -z-0 transition-colors ${
                        isPast ? "bg-emerald-500" : "bg-slate-700"
                      }`}
                    />
                  )}

                  {/* Icon Circle */}
                  <div
                    className={`w-9 h-9 rounded-full flex items-center justify-center shrink-0 z-10 font-bold text-xs transition-all ${
                      isPast
                        ? "bg-emerald-500 text-slate-950 ring-4 ring-emerald-500/20"
                        : isCurrent
                        ? "bg-emerald-500/20 text-emerald-400 border-2 border-emerald-400 ring-4 ring-emerald-500/10 animate-pulse"
                        : "bg-slate-800 text-slate-500 border border-slate-700"
                    }`}
                  >
                    {isPast ? <CheckCircle2 className="w-4 h-4" /> : idx + 1}
                  </div>

                  {/* Step Label */}
                  <div className="pt-1">
                    <div className="flex items-center gap-2">
                      <span
                        className={`text-sm font-semibold ${
                          isCurrent ? "text-emerald-300" : isPast ? "text-white" : "text-slate-500"
                        }`}
                      >
                        {step.label}
                      </span>
                      {isCurrent && (
                        <span className="text-[10px] bg-emerald-500/20 text-emerald-300 px-2 py-0.5 rounded-full border border-emerald-500/30">
                          Active Stage
                        </span>
                      )}
                    </div>
                    <p className="text-xs text-slate-400 mt-0.5">{step.desc}</p>
                  </div>
                </div>
              );
            })}
          </div>

          {/* Dynamic ETA & Collector Badge */}
          {statusData?.collector_assigned ? (
            <div className="bg-emerald-950/40 border border-emerald-500/40 rounded-xl p-4 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0">
                  <Truck className="w-5 h-5" />
                </div>
                <div>
                  <div className="text-xs text-slate-300 font-medium">Assigned Collector</div>
                  <div className="text-sm font-bold text-white flex items-center gap-1.5">
                    <span>{statusData.collector_id ? `Collector ${statusData.collector_id.slice(0, 8)}` : "Nearby Kabadiwala"}</span>
                    <ShieldCheck className="w-4 h-4 text-emerald-400" />
                  </div>
                  {statusData.arrival_eta && (
                    <div className="text-xs text-emerald-300 mt-0.5 font-medium flex items-center gap-1">
                      <Clock className="w-3 h-3" />
                      <span>{statusData.arrival_eta}</span>
                    </div>
                  )}
                </div>
              </div>
            </div>
          ) : (
            <div className="bg-slate-900/60 border border-slate-700 rounded-xl p-4 flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-amber-500/10 text-amber-400 flex items-center justify-center shrink-0">
                <Clock className="w-5 h-5" />
              </div>
              <div>
                <div className="text-xs font-semibold text-slate-200">Broadcasting to Nearby Collectors</div>
                <div className="text-xs text-slate-400">
                  Request active within 2.5 km radius. You will see live ETA once accepted.
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Security & Verification Note */}
        <div className="text-xs text-slate-400 bg-slate-800/30 border border-slate-800 rounded-xl p-4 flex items-start gap-2.5">
          <ShieldCheck className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
          <p>
            When the collector arrives, they will weigh the material on their scale, verify the price against the 
            official market board, and hand over cash in hand. No digital login or Aadhaar needed.
          </p>
        </div>
      </main>

      <footer className="border-t border-slate-800 py-4 px-4 text-center text-xs text-slate-500">
        Kabadiwala Connect — JNARDDC
      </footer>
    </div>
  );
}
