"use client";

import React from "react";
import { useLanguage } from "../../context/LanguageContext";
import { AlertTriangle, Calendar, Phone, Mail, Building2, RefreshCw } from "lucide-react";

interface ExpiringRecycler {
  id: string;
  name: string;
  authNo: string;
  daysRemaining: number;
  expiryDate: string;
  phone: string;
  email: string;
  location: string;
}

const mockExpiringRecyclers: ExpiringRecycler[] = [
  {
    id: "REC-EXP-01",
    name: "Apex E-Waste Recyclers & Refining",
    authNo: "MPCB/EPR/2021/REC-1092",
    daysRemaining: 12,
    expiryDate: "2026-10-07",
    phone: "+91 98210 11223",
    email: "compliance@apexrecycle.in",
    location: "Turbhe MIDC, Navi Mumbai",
  },
  {
    id: "REC-EXP-02",
    name: "Nagpur Green Dismantlers Co.",
    authNo: "CPCB/EPR/2021/NG-440",
    daysRemaining: 24,
    expiryDate: "2026-10-19",
    phone: "+91 94221 55667",
    email: "admin@nagpurgreen.org",
    location: "Hingna Industrial Estate, Nagpur",
  },
];

export function AdminExpiryAlertsView() {
  const { t } = useLanguage();

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-2xl font-extrabold text-white">{t.navExpiryAlerts}</h1>
          <p className="text-xs text-slate-400 mt-1">
            Recyclers with authorizations expiring within 30 days requiring renewal audits
          </p>
        </div>
        <button
          className="bg-slate-800 hover:bg-slate-700 text-amber-300 border border-amber-600/40 text-xs font-bold px-4 py-2 rounded-xl flex items-center space-x-2"
          onClick={() => alert("Automated renewal notification emails dispatched to expiring recyclers.")}
        >
          <RefreshCw className="w-4 h-4" />
          <span>Dispatch Renewal Notices</span>
        </button>
      </div>

      <div className="space-y-4">
        {mockExpiringRecyclers.map((rec) => (
          <div
            key={rec.id}
            className="bg-slate-900 border border-amber-900/60 rounded-2xl p-6 shadow-xl space-y-4 hover:border-amber-700 transition"
          >
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-2 border-b border-slate-800 pb-3">
              <div className="flex items-center space-x-3">
                <div className="p-2.5 rounded-xl bg-amber-950 text-amber-400 border border-amber-800">
                  <AlertTriangle className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-base font-extrabold text-white">{rec.name}</h3>
                  <p className="text-xs text-slate-400">{rec.location}</p>
                </div>
              </div>
              <div className="text-right">
                <span className="text-xs font-black text-amber-400 bg-amber-950 px-3 py-1 rounded-full border border-amber-800">
                  Expires in {rec.daysRemaining} Days
                </span>
                <span className="text-[11px] text-slate-400 block mt-1">
                  Valid till: {rec.expiryDate}
                </span>
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs">
              <div className="bg-slate-800/60 p-3 rounded-xl">
                <span className="text-slate-400 text-[10px] font-bold block">
                  AUTHORIZATION NO
                </span>
                <span className="text-white font-mono font-bold">{rec.authNo}</span>
              </div>
              <div className="bg-slate-800/60 p-3 rounded-xl flex items-center space-x-2">
                <Phone className="w-4 h-4 text-emerald-400" />
                <span className="text-slate-300 font-mono">{rec.phone}</span>
              </div>
              <div className="bg-slate-800/60 p-3 rounded-xl flex items-center space-x-2">
                <Mail className="w-4 h-4 text-blue-400" />
                <span className="text-slate-300">{rec.email}</span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
