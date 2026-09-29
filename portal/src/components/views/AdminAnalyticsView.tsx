"use client";

import React from "react";
import { useLanguage } from "../../context/LanguageContext";
import {
  Download,
  BarChart3,
  TrendingUp,
  Award,
  CheckCircle2,
  Users,
  ShieldCheck,
} from "lucide-react";

export function AdminAnalyticsView() {
  const { t } = useLanguage();

  const districtVolumes = [
    { district: "Mumbai", volumeKg: 52000, pct: 100 },
    { district: "Pune", volumeKg: 44000, pct: 85 },
    { district: "Thane", volumeKg: 38000, pct: 73 },
    { district: "Nagpur", volumeKg: 29000, pct: 56 },
    { district: "Nashik", volumeKg: 22000, pct: 42 },
    { district: "Palghar", volumeKg: 16000, pct: 31 },
  ];

  const monthlyGrowth = [
    { month: "May", formalKg: 85000, targetKg: 75000 },
    { month: "Jun", formalKg: 110000, targetKg: 90000 },
    { month: "Jul", formalKg: 135000, targetKg: 110000 },
    { month: "Aug", formalKg: 172000, targetKg: 140000 },
    { month: "Sep", formalKg: 201000, targetKg: 160000 },
  ];

  const handleExportCsv = () => {
    const csvContent =
      "data:text/csv;charset=utf-8," +
      "district,category,weight_kg,formal_channel,anonymized_collector_hash,timestamp\n" +
      "Mumbai,PCB,12.5,true,e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855,2026-09-25T10:30:00Z\n" +
      "Pune,Batteries,24.0,true,1a8565a9dae5b43fc116561da9b620e6b683a4c1ad9f134a0247b7a9fed00c82,2026-09-25T11:15:00Z\n" +
      "Thane,Cables,8.0,true,3f79bb7b435b05321651daefd374cdc681dc06faa65e374e38337b88ca14539f,2026-09-25T12:00:00Z\n";

    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", "kabadiwala_anonymized_ewaste_dataset.csv");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-2xl font-extrabold text-white">{t.navAnalytics}</h1>
          <p className="text-xs text-slate-400 mt-1">
            JNARDDC & CPCB Mass Balance, Formal Channel Divergence, and Quality Governance
          </p>
        </div>

        <button
          onClick={handleExportCsv}
          data-testid="btn-export-csv"
          className="bg-emerald-600 hover:bg-emerald-500 text-white font-extrabold px-5 py-2.5 rounded-xl shadow-lg shadow-emerald-900/40 text-xs flex items-center space-x-2 transition"
        >
          <Download className="w-4 h-4" />
          <span>{t.btnExportCsv}</span>
        </button>
      </div>

      {/* 4 Top Highlight Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Data Quality Scorecard */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-xl flex items-center space-x-4">
          <div className="w-14 h-14 rounded-2xl bg-emerald-950 border border-emerald-600 flex items-center justify-center font-black text-2xl text-emerald-400">
            91.7
          </div>
          <div>
            <span className="text-[10px] uppercase font-bold text-slate-400 block">
              {t.dataQualityScore}
            </span>
            <span className="text-base font-extrabold text-white">91.7/100 Grade A</span>
            <p className="text-[11px] text-emerald-400 mt-0.5">IQR Cleaned • Anonymized</p>
          </div>
        </div>

        {/* Formal Channel Volume */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-xl flex items-center space-x-4">
          <div className="w-14 h-14 rounded-2xl bg-blue-950 border border-blue-600 flex items-center justify-center font-black text-xl text-blue-400">
            201T
          </div>
          <div>
            <span className="text-[10px] uppercase font-bold text-slate-400 block">
              Formal Channel Intake
            </span>
            <span className="text-base font-extrabold text-white">+25.6% vs Target</span>
            <p className="text-[11px] text-blue-400 mt-0.5">Direct to Authorized EPR</p>
          </div>
        </div>

        {/* Collector Premium */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-xl flex items-center space-x-4">
          <div className="w-14 h-14 rounded-2xl bg-amber-950 border border-amber-600 flex items-center justify-center font-black text-xl text-amber-400">
            +18%
          </div>
          <div>
            <span className="text-[10px] uppercase font-bold text-slate-400 block">
              Collector Realized Premium
            </span>
            <span className="text-base font-extrabold text-white">Fair Benchmark Price</span>
            <p className="text-[11px] text-amber-400 mt-0.5">Guaranteed Cash Floor</p>
          </div>
        </div>

        {/* Earnings Lift Card */}
        <div
          data-testid="earnings-lift-metric"
          className="bg-slate-900 border border-emerald-800/80 rounded-2xl p-5 shadow-xl flex items-center space-x-4 ring-1 ring-emerald-500/30"
        >
          <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-emerald-900 to-emerald-700 border border-emerald-400 flex items-center justify-center font-black text-2xl text-emerald-200 shadow-lg shadow-emerald-950">
            +70%
          </div>
          <div>
            <span className="text-[10px] uppercase font-bold text-slate-400 block">
              Earnings Lift (Comparison)
            </span>
            <span className="text-base font-extrabold text-emerald-400">+70% Net Income Lift</span>
            <p className="text-[11px] text-slate-300 mt-0.5">Direct Recycler vs Middlemen</p>
          </div>
        </div>
      </div>

      {/* Charts Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* District Intake Bar Chart Visual */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl space-y-4">
          <div className="flex justify-between items-center">
            <h3 className="text-sm font-extrabold text-white flex items-center gap-2">
              <BarChart3 className="w-4 h-4 text-emerald-400" />
              <span>E-Waste Inflow by District (Maharashtra)</span>
            </h3>
            <span className="text-xs text-slate-400 font-mono">Total: 201 MT</span>
          </div>

          <div className="space-y-3 pt-2">
            {districtVolumes.map((d) => (
              <div key={d.district} className="space-y-1">
                <div className="flex justify-between text-xs font-bold text-slate-300">
                  <span>{d.district}</span>
                  <span className="text-white">{(d.volumeKg / 1000).toFixed(1)} MT</span>
                </div>
                <div className="w-full bg-slate-800 rounded-full h-3 overflow-hidden">
                  <div
                    className="bg-gradient-to-r from-emerald-500 to-teal-400 h-3 rounded-full transition-all duration-700"
                    style={{ width: `${d.pct}%` }}
                  ></div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Growth Trend & Collector Comparison */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl space-y-4 flex flex-col justify-between">
          <div>
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-sm font-extrabold text-white flex items-center gap-2">
                <TrendingUp className="w-4 h-4 text-blue-400" />
                <span>Formal-Channel EPR Growth vs Target (MT)</span>
              </h3>
              <span className="text-xs text-emerald-400 font-bold">+136% 5-Mo Growth</span>
            </div>

            <div className="grid grid-cols-5 gap-2 h-44 items-end pt-4 px-2 border-b border-slate-800 pb-2">
              {monthlyGrowth.map((m) => {
                const heightPct = Math.round((m.formalKg / 220000) * 100);
                return (
                  <div key={m.month} className="flex flex-col items-center gap-1.5 h-full justify-end">
                    <span className="text-[10px] font-bold text-emerald-400">
                      {(m.formalKg / 1000).toFixed(0)}T
                    </span>
                    <div
                      className="w-full max-w-[28px] bg-gradient-to-t from-emerald-600 to-emerald-400 rounded-t-lg shadow transition-all duration-700"
                      style={{ height: `${heightPct}%` }}
                    ></div>
                    <span className="text-[11px] font-bold text-slate-400">{m.month}</span>
                  </div>
                );
              })}
            </div>
          </div>

          <div className="bg-slate-800/60 p-3.5 rounded-xl border border-slate-700/80 text-xs text-slate-300 flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <Users className="w-4 h-4 text-emerald-400" />
              <span>Avg Kabadiwala Monthly Payout:</span>
            </div>
            <span className="text-base font-black text-emerald-400">₹14,250</span>
          </div>
        </div>
      </div>
    </div>
  );
}
