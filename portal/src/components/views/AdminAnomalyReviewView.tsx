"use client";

import React, { useState } from "react";
import { useLanguage } from "../../context/LanguageContext";
import { mockAnomalies } from "../../lib/api";
import { AnomalyItem } from "../../lib/types";
import { ShieldAlert, CheckCircle2, AlertOctagon, ArrowRight, ShieldCheck } from "lucide-react";

export function AdminAnomalyReviewView() {
  const { t } = useLanguage();
  const [anomalies, setAnomalies] = useState<AnomalyItem[]>(mockAnomalies);
  const [actionMsg, setActionMsg] = useState<string | null>(null);

  const handleResolve = (id: string) => {
    setAnomalies((prev) =>
      prev.map((a) => (a.id === id ? { ...a, status: "resolved" } : a))
    );
    setActionMsg(`Anomaly ${id} resolved and cleared.`);
    setTimeout(() => setActionMsg(null), 4000);
  };

  const handleEscalate = (id: string) => {
    setAnomalies((prev) =>
      prev.map((a) => (a.id === id ? { ...a, status: "escalated" } : a))
    );
    setActionMsg(`Anomaly ${id} escalated for formal CPCB/JNARDDC field audit.`);
    setTimeout(() => setActionMsg(null), 4000);
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-2xl font-extrabold text-white">{t.navAnomalies}</h1>
          <p className="text-xs text-slate-400 mt-1">
            Isolation Forest ML & Domain Rule flagged transactions requiring compliance review
          </p>
        </div>
        <span className="px-3 py-1 bg-red-950 text-red-300 border border-red-800 rounded-lg text-xs font-bold flex items-center gap-1.5">
          <ShieldAlert className="w-4 h-4" />
          <span>{anomalies.filter((a) => a.status === "pending_review").length} Open Anomalies</span>
        </span>
      </div>

      {actionMsg && (
        <div className="bg-emerald-950/90 border border-emerald-600 text-emerald-200 px-4 py-3 rounded-xl flex items-center space-x-2 text-sm font-semibold">
          <CheckCircle2 className="w-5 h-5 text-emerald-400" />
          <span>{actionMsg}</span>
        </div>
      )}

      <div className="space-y-4">
        {anomalies.map((anom) => {
          const isPending = anom.status === "pending_review";

          return (
            <div
              key={anom.id}
              data-testid={`anomaly-card-${anom.id}`}
              className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl space-y-4 hover:border-slate-700 transition"
            >
              <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-2 border-b border-slate-800 pb-3">
                <div>
                  <div className="flex items-center space-x-2">
                    <span className="font-mono text-red-400 font-extrabold text-sm">
                      {anom.id}
                    </span>
                    <span className="text-xs font-mono bg-slate-800 text-slate-300 px-2 py-0.5 rounded">
                      Lot: {anom.lotId}
                    </span>
                    <span className="text-xs font-mono text-slate-400">
                      Col: {anom.collectorRefId}
                    </span>
                  </div>
                  <p className="text-xs text-slate-300 font-semibold mt-1">
                    {anom.category} • {anom.weightKg} kg • Total: ₹{anom.finalPrice} (₹{anom.pricePerKg}/kg)
                  </p>
                </div>

                <div className="flex items-center space-x-2">
                  <span
                    className={`text-xs font-bold px-3 py-1 rounded-full uppercase border ${
                      anom.status === "resolved"
                        ? "bg-emerald-950 text-emerald-300 border-emerald-600"
                        : anom.status === "escalated"
                        ? "bg-red-950 text-red-300 border-red-600"
                        : "bg-amber-950 text-amber-300 border-amber-600"
                    }`}
                  >
                    {anom.status.replace("_", " ")}
                  </span>
                </div>
              </div>

              {/* Flags & Reasons */}
              <div className="space-y-2">
                <div className="flex flex-wrap gap-1.5">
                  {anom.flags.map((fl) => (
                    <span
                      key={fl}
                      className="bg-red-950/80 text-red-300 border border-red-800 text-[10px] font-mono font-bold px-2 py-0.5 rounded"
                    >
                      {fl}
                    </span>
                  ))}
                </div>

                <div className="bg-slate-950 border border-slate-800 p-3.5 rounded-xl text-xs text-slate-300 space-y-1">
                  <span className="text-[10px] font-bold uppercase text-slate-500 block">
                    DETECTION RATIONALE (ENGLISH / VERNACULAR READY):
                  </span>
                  {anom.reasons.map((r, i) => (
                    <p key={i} className="text-red-200">
                      • {r}
                    </p>
                  ))}
                </div>
              </div>

              {/* Action Buttons */}
              {isPending && (
                <div className="flex justify-end space-x-3 pt-2">
                  <button
                    onClick={() => handleResolve(anom.id)}
                    data-testid={`btn-resolve-${anom.id}`}
                    className="bg-emerald-600 hover:bg-emerald-500 text-white font-extrabold px-4 py-2 rounded-xl text-xs flex items-center space-x-1.5 shadow"
                  >
                    <CheckCircle2 className="w-4 h-4" />
                    <span>{t.btnResolve}</span>
                  </button>

                  <button
                    onClick={() => handleEscalate(anom.id)}
                    data-testid={`btn-escalate-${anom.id}`}
                    className="bg-slate-800 hover:bg-red-950 text-red-300 border border-red-800 font-bold px-4 py-2 rounded-xl text-xs flex items-center space-x-1.5"
                  >
                    <AlertOctagon className="w-4 h-4" />
                    <span>{t.btnEscalate}</span>
                  </button>
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
