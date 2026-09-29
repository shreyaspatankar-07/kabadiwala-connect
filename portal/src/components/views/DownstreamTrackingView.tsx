"use client";

import React, { useState } from "react";
import { useLanguage } from "../../context/LanguageContext";
import { mockHandoverRecords } from "../../lib/api";
import { HandoverRecord } from "../../lib/types";
import {
  Truck,
  CheckCircle2,
  FileCheck,
  Flame,
  ArrowRight,
  ShieldCheck,
} from "lucide-react";

export function DownstreamTrackingView() {
  const { t } = useLanguage();
  const [records, setRecords] = useState<HandoverRecord[]>(mockHandoverRecords);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);
  const [pendingStages, setPendingStages] = useState<Record<string, string>>({});

  const stages = [
    { id: "received", label: t.stageReceived, icon: Truck },
    { id: "dismantled", label: t.stageDismantled, icon: Flame },
    { id: "processed", label: t.stageProcessed, icon: CheckCircle2 },
    { id: "certificate_issued", label: t.stageCertified, icon: FileCheck },
  ];

  const handleUpdateStage = (refNo: string, newStage?: string) => {
    const stageToApply = newStage || pendingStages[refNo] || "dismantled";
    setRecords((prev) =>
      prev.map((r) =>
        r.handoverRefNo === refNo ? { ...r, downstreamStatus: stageToApply as any } : r
      )
    );
    setSuccessMsg(`Lot ${refNo} advanced to stage: ${stageToApply.toUpperCase()}`);
    setTimeout(() => setSuccessMsg(null), 4000);
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-extrabold text-white">{t.navDownstream}</h1>
        <p className="text-xs text-slate-400 mt-1">
          Update processing lifecycle stages under EPR target tracking
        </p>
      </div>

      {successMsg && (
        <div className="bg-emerald-950/90 border border-emerald-600 text-emerald-200 px-4 py-3 rounded-xl flex items-center space-x-2 text-sm font-semibold">
          <CheckCircle2 className="w-5 h-5 text-emerald-400" />
          <span>{successMsg}</span>
        </div>
      )}

      <div className="space-y-4">
        {records.map((rec) => {
          const currentStageIndex = stages.findIndex(
            (s) => s.id === rec.downstreamStatus
          );

          return (
            <div
              key={rec.handoverRefNo}
              className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl space-y-6"
            >
              {/* Header Info */}
              <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-2 border-b border-slate-800 pb-4">
                <div>
                  <div className="flex items-center space-x-2">
                    <span className="font-mono text-emerald-400 font-extrabold text-base">
                      {rec.handoverRefNo}
                    </span>
                    <span className="text-xs bg-slate-800 text-slate-300 px-2 py-0.5 rounded font-mono">
                      {rec.lotId}
                    </span>
                  </div>
                  <p className="text-xs text-slate-400 mt-0.5">
                    {rec.category} • {rec.measuredWeightKg} kg • Final Payout: ₹{rec.finalPrice}
                  </p>
                </div>

                {/* Stage Select Dropdown & Update Status Button */}
                <div className="flex items-center space-x-2 w-full sm:w-auto">
                  <select
                    value={pendingStages[rec.handoverRefNo] ?? rec.downstreamStatus}
                    onChange={(e) =>
                      setPendingStages((prev) => ({
                        ...prev,
                        [rec.handoverRefNo]: e.target.value,
                      }))
                    }
                    data-testid={`select-stage-${rec.handoverRefNo}`}
                    className="bg-slate-800 border border-slate-700 text-white text-xs font-bold rounded-xl px-3 py-2.5 focus:outline-none focus:border-emerald-500"
                  >
                    {stages.map((st) => (
                      <option key={st.id} value={st.id}>
                        {st.label}
                      </option>
                    ))}
                  </select>

                  <button
                    type="button"
                    data-testid={`btn-update-status-${rec.handoverRefNo}`}
                    onClick={() => handleUpdateStage(rec.handoverRefNo)}
                    className="bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-bold px-3 py-2.5 rounded-xl transition shadow flex items-center space-x-1"
                  >
                    <span>Update Status</span>
                  </button>
                </div>
              </div>

              {/* 4-Step Visual Progression Bar */}
              <div className="grid grid-cols-1 sm:grid-cols-4 gap-3 pt-2">
                {stages.map((st, idx) => {
                  const Icon = st.icon;
                  const isCompleted = idx <= currentStageIndex;
                  const isCurrent = idx === currentStageIndex;

                  return (
                    <div
                      key={st.id}
                      className={`p-3 rounded-xl border flex items-center space-x-3 transition ${
                        isCompleted
                          ? "bg-emerald-950/60 border-emerald-700/80 text-white"
                          : "bg-slate-950/60 border-slate-800 text-slate-500"
                      } ${isCurrent ? "ring-2 ring-emerald-500" : ""}`}
                    >
                      <div
                        className={`w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0 ${
                          isCompleted
                            ? "bg-emerald-600 text-white"
                            : "bg-slate-800 text-slate-500"
                        }`}
                      >
                        <Icon className="w-4 h-4" />
                      </div>
                      <div className="min-w-0">
                        <p className="text-[10px] uppercase font-bold text-slate-400">
                          Step {idx + 1}
                        </p>
                        <p className="text-xs font-extrabold truncate text-white">
                          {st.label.split(". ")[1]}
                        </p>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
