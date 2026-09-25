"use client";

import React, { useState } from "react";
import { useLanguage } from "../../context/LanguageContext";
import { CheckCircle2, XCircle, AlertOctagon, FileCheck, ShieldCheck, Building2 } from "lucide-react";

interface PendingRecyclerItem {
  id: string;
  name: string;
  authNo: string;
  body: string;
  location: string;
  materials: string[];
  docRef: string;
  appliedAt: string;
  status: "pending" | "verified" | "suspended" | "rejected";
}

const mockPendingRecyclers: PendingRecyclerItem[] = [
  {
    id: "REC-P01",
    name: "GreenEarth E-Waste Solutions",
    authNo: "MPCB/EPR/2026/P-8819",
    body: "MPCB",
    location: "Bhiwandi, Thane, Maharashtra",
    materials: ["PCB", "Cables", "Batteries"],
    docRef: "MPCB_Consent_to_Operate_2026.pdf",
    appliedAt: "2026-09-24",
    status: "pending",
  },
  {
    id: "REC-P02",
    name: "Western India Metals & Dismantlers",
    authNo: "CPCB/EPR/2026/MH-102",
    body: "CPCB",
    location: "Chakan, Pune, Maharashtra",
    materials: ["Motors_Magnets", "CRT", "Mixed_Plastics"],
    docRef: "CPCB_Authorization_Grant.pdf",
    appliedAt: "2026-09-23",
    status: "pending",
  },
];

export function AdminVerificationQueueView() {
  const { t } = useLanguage();
  const [queue, setQueue] = useState<PendingRecyclerItem[]>(mockPendingRecyclers);
  const [notification, setNotification] = useState<string | null>(null);

  const handleAction = (id: string, newStatus: "verified" | "suspended" | "rejected") => {
    setQueue((prev) =>
      prev.map((r) => (r.id === id ? { ...r, status: newStatus } : r))
    );
    setNotification(`Recycler ${id} status updated to: ${newStatus.toUpperCase()}`);
    setTimeout(() => setNotification(null), 4000);
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-2xl font-extrabold text-white">{t.navVerificationQueue}</h1>
          <p className="text-xs text-slate-400 mt-1">
            Review and approve authorized e-waste aggregators & recyclers under E-Waste Rules 2022
          </p>
        </div>
        <span className="px-3 py-1 bg-amber-950 text-amber-300 border border-amber-800 rounded-lg text-xs font-bold">
          {queue.filter((q) => q.status === "pending").length} Pending Audits
        </span>
      </div>

      {notification && (
        <div className="bg-emerald-950/90 border border-emerald-600 text-emerald-200 px-4 py-3 rounded-xl flex items-center space-x-2 text-sm font-semibold">
          <CheckCircle2 className="w-5 h-5 text-emerald-400" />
          <span>{notification}</span>
        </div>
      )}

      <div className="space-y-4">
        {queue.map((rec) => (
          <div
            key={rec.id}
            data-testid={`recycler-verification-${rec.id}`}
            className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl space-y-4 hover:border-slate-700 transition"
          >
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-2 border-b border-slate-800 pb-3">
              <div>
                <div className="flex items-center space-x-2">
                  <Building2 className="w-5 h-5 text-amber-400" />
                  <h3 className="text-base font-extrabold text-white">{rec.name}</h3>
                  <span className="text-xs font-mono bg-slate-800 text-slate-300 px-2 py-0.5 rounded">
                    {rec.id}
                  </span>
                </div>
                <p className="text-xs text-slate-400 mt-0.5">{rec.location}</p>
              </div>

              <span
                className={`text-xs font-bold px-3 py-1 rounded-full uppercase border ${
                  rec.status === "verified"
                    ? "bg-emerald-950 text-emerald-300 border-emerald-600"
                    : rec.status === "rejected"
                    ? "bg-red-950 text-red-300 border-red-600"
                    : "bg-amber-950 text-amber-300 border-amber-600"
                }`}
              >
                {rec.status}
              </span>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs">
              <div className="bg-slate-800/60 p-3 rounded-xl">
                <span className="text-slate-400 text-[10px] font-bold block">
                  AUTHORIZATION NO ({rec.body})
                </span>
                <span className="text-white font-mono font-bold">{rec.authNo}</span>
              </div>
              <div className="bg-slate-800/60 p-3 rounded-xl">
                <span className="text-slate-400 text-[10px] font-bold block">
                  MATERIALS APPLIED
                </span>
                <span className="text-emerald-400 font-bold">
                  {rec.materials.join(", ")}
                </span>
              </div>
              <div className="bg-slate-800/60 p-3 rounded-xl flex items-center justify-between">
                <div>
                  <span className="text-slate-400 text-[10px] font-bold block">
                    CONSENT DOCUMENT
                  </span>
                  <span className="text-blue-300 font-mono text-[11px] truncate block max-w-[150px]">
                    {rec.docRef}
                  </span>
                </div>
                <FileCheck className="w-5 h-5 text-blue-400" />
              </div>
            </div>

            {/* Action Buttons */}
            {rec.status === "pending" && (
              <div className="flex justify-end space-x-3 pt-2">
                <button
                  onClick={() => handleAction(rec.id, "verified")}
                  data-testid={`btn-approve-${rec.id}`}
                  className="bg-emerald-600 hover:bg-emerald-500 text-white font-extrabold px-4 py-2 rounded-xl text-xs flex items-center space-x-1.5 shadow"
                >
                  <CheckCircle2 className="w-4 h-4" />
                  <span>{t.btnApprove}</span>
                </button>
                <button
                  onClick={() => handleAction(rec.id, "suspended")}
                  data-testid={`btn-suspend-${rec.id}`}
                  className="bg-slate-800 hover:bg-amber-950 text-amber-300 border border-amber-700 font-bold px-4 py-2 rounded-xl text-xs flex items-center space-x-1.5"
                >
                  <AlertOctagon className="w-4 h-4" />
                  <span>{t.btnSuspend}</span>
                </button>
                <button
                  onClick={() => handleAction(rec.id, "rejected")}
                  data-testid={`btn-reject-${rec.id}`}
                  className="bg-slate-800 hover:bg-red-950 text-red-300 border border-red-700 font-bold px-4 py-2 rounded-xl text-xs flex items-center space-x-1.5"
                >
                  <XCircle className="w-4 h-4" />
                  <span>{t.btnReject}</span>
                </button>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
