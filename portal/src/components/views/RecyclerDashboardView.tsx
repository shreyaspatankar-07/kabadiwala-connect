"use client";

import React from "react";
import { useLanguage } from "../../context/LanguageContext";
import { mockDashboardMetrics, mockRecyclerProfile } from "../../lib/api";
import { Weight, IndianRupee, Clock, ArrowUpRight, CheckCircle2, TrendingUp } from "lucide-react";

export function RecyclerDashboardView() {
  const { t } = useLanguage();
  const metrics = mockDashboardMetrics;

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="bg-gradient-to-r from-emerald-900 via-slate-900 to-slate-900 rounded-2xl p-6 border border-emerald-800/40 text-white shadow-xl">
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
          <div>
            <div className="flex items-center space-x-2">
              <span className="px-2.5 py-0.5 rounded-full text-xs font-bold bg-emerald-500/20 text-emerald-300 border border-emerald-500/40">
                {mockRecyclerProfile.authorizationNumber}
              </span>
              <span className="text-xs text-slate-400">
                Valid till: {mockRecyclerProfile.authorizationValidTill}
              </span>
            </div>
            <h1 className="text-2xl font-black mt-1 text-white">
              {mockRecyclerProfile.name}
            </h1>
            <p className="text-xs text-emerald-300/80 mt-1">
              Authorized E-Waste Dismantler & Recycler • CPCB/MPCB Verified
            </p>
          </div>
          <div className="flex items-center space-x-2 bg-emerald-950/80 px-4 py-2 rounded-xl border border-emerald-700/60">
            <CheckCircle2 className="w-5 h-5 text-emerald-400" />
            <div>
              <p className="text-[10px] uppercase font-bold text-emerald-400">EPR Status</p>
              <p className="text-sm font-extrabold text-white">100% Compliant</p>
            </div>
          </div>
        </div>
      </div>

      {/* 4 Summary Stat Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Total Volume */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-lg">
          <div className="flex justify-between items-start">
            <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">
              {t.statTotalVolume}
            </span>
            <div className="p-2 rounded-xl bg-emerald-500/10 text-emerald-400">
              <Weight className="w-5 h-5" />
            </div>
          </div>
          <div className="mt-4">
            <h3 className="text-3xl font-black text-white">
              {(metrics.totalVolumeMonthKg / 1000).toFixed(1)}{" "}
              <span className="text-lg font-bold text-emerald-400">MT</span>
            </h3>
            <p className="text-xs text-slate-400 mt-1 flex items-center">
              <TrendingUp className="w-3.5 h-3.5 text-emerald-400 mr-1" />
              <span>{metrics.totalVolumeMonthKg.toLocaleString()} kg collected</span>
            </p>
          </div>
        </div>

        {/* Total Spend */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-lg">
          <div className="flex justify-between items-start">
            <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">
              {t.statTotalSpend}
            </span>
            <div className="p-2 rounded-xl bg-emerald-500/10 text-emerald-400">
              <IndianRupee className="w-5 h-5" />
            </div>
          </div>
          <div className="mt-4">
            <h3 className="text-3xl font-black text-white">
              ₹{(metrics.totalSpendMonth / 100000).toFixed(2)}{" "}
              <span className="text-lg font-bold text-emerald-400">Lakh</span>
            </h3>
            <p className="text-xs text-slate-400 mt-1">
              Direct cash & digital payout to collectors
            </p>
          </div>
        </div>

        {/* Pending Payments */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-lg">
          <div className="flex justify-between items-start">
            <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">
              {t.statPendingPayments}
            </span>
            <div className="p-2 rounded-xl bg-amber-500/10 text-amber-400">
              <Clock className="w-5 h-5" />
            </div>
          </div>
          <div className="mt-4">
            <h3 className="text-3xl font-black text-amber-400">
              {metrics.pendingPaymentsCount}{" "}
              <span className="text-sm font-semibold text-slate-400">Lots</span>
            </h3>
            <p className="text-xs text-amber-400/80 mt-1">
              Pending cash receipt confirmation
            </p>
          </div>
        </div>

        {/* Active Incoming Matches */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-lg">
          <div className="flex justify-between items-start">
            <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">
              {t.statActiveMatches}
            </span>
            <div className="p-2 rounded-xl bg-blue-500/10 text-blue-400">
              <ArrowUpRight className="w-5 h-5" />
            </div>
          </div>
          <div className="mt-4">
            <h3 className="text-3xl font-black text-blue-400">
              {metrics.activeMatchesCount}{" "}
              <span className="text-sm font-semibold text-slate-400">Available</span>
            </h3>
            <p className="text-xs text-blue-400/80 mt-1">
              Nearby lots awaiting acceptance
            </p>
          </div>
        </div>
      </div>

      {/* Category Volumes & Average Rates Card */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Category Volume Breakdown */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl">
          <h3 className="text-base font-extrabold text-white mb-4 flex items-center justify-between">
            <span>Material Intake by Category (kg)</span>
            <span className="text-xs font-semibold text-emerald-400 bg-emerald-950/80 px-2 py-1 rounded-lg border border-emerald-800/60">
              Monthly Intake
            </span>
          </h3>
          <div className="space-y-3">
            {Object.entries(metrics.categoryVolumes).map(([cat, vol]) => {
              const maxVol = 5000;
              const pct = Math.min(100, (vol / maxVol) * 100);
              return (
                <div key={cat} className="space-y-1">
                  <div className="flex justify-between text-xs font-bold text-slate-300">
                    <span>{cat}</span>
                    <span className="text-white">{vol.toLocaleString()} kg</span>
                  </div>
                  <div className="w-full bg-slate-800 rounded-full h-2.5 overflow-hidden">
                    <div
                      className="bg-emerald-500 h-2.5 rounded-full transition-all duration-500"
                      style={{ width: `${pct}%` }}
                    ></div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Offered Category Rates Card */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl">
          <h3 className="text-base font-extrabold text-white mb-4 flex items-center justify-between">
            <span>Current Offered Rates (₹/kg)</span>
            <span className="text-xs text-slate-400">Live Rate Card</span>
          </h3>
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
            {Object.entries(mockRecyclerProfile.offeredRates).map(([cat, rate]) => (
              <div
                key={cat}
                className="bg-slate-800/80 border border-slate-700/80 rounded-xl p-3 text-center"
              >
                <p className="text-[11px] font-bold text-slate-400 truncate">{cat}</p>
                <p className="text-lg font-black text-emerald-400 mt-1">₹{rate}</p>
                <p className="text-[10px] text-slate-500">per kg</p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
