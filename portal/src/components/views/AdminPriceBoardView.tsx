"use client";

import React, { useState } from "react";
import { useLanguage } from "../../context/LanguageContext";
import { mockPriceBoards } from "../../lib/api";
import { EwasteCategory, PriceBoardItem } from "../../lib/types";
import { TrendingUp, ArrowUpRight, ArrowDownRight, Minus, Edit3, CheckCircle2 } from "lucide-react";

export function AdminPriceBoardView() {
  const { t } = useLanguage();
  const [prices, setPrices] = useState<PriceBoardItem[]>(mockPriceBoards);
  const [overrideDistrict, setOverrideDistrict] = useState("Mumbai");
  const [overrideCategory, setOverrideCategory] = useState<EwasteCategory>("PCB");
  const [newRate, setNewRate] = useState("430");
  const [overrideMsg, setOverrideMsg] = useState<string | null>(null);

  const handleOverride = (e: React.FormEvent) => {
    e.preventDefault();
    const rate = parseFloat(newRate) || 0;
    setPrices((prev) =>
      prev.map((p) =>
        p.district === overrideDistrict && p.category === overrideCategory
          ? {
              ...p,
              buyingPrice: rate,
              isOverridden: true,
              lastUpdated: new Date().toISOString(),
            }
          : p
      )
    );
    setOverrideMsg(
      `Price for ${overrideDistrict} - ${overrideCategory} overridden to ₹${rate}/kg.`
    );
    setTimeout(() => setOverrideMsg(null), 4000);
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-extrabold text-white">{t.navPriceBoard}</h1>
        <p className="text-xs text-slate-400 mt-1">
          Monitor rolling benchmark prices and manually enforce price stability ceilings
        </p>
      </div>

      {overrideMsg && (
        <div className="bg-emerald-950/90 border border-emerald-600 text-emerald-200 px-4 py-3 rounded-xl flex items-center space-x-2 text-sm font-semibold">
          <CheckCircle2 className="w-5 h-5 text-emerald-400" />
          <span>{overrideMsg}</span>
        </div>
      )}

      {/* Override Form */}
      <form
        onSubmit={handleOverride}
        className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl space-y-4"
      >
        <h3 className="text-base font-extrabold text-white flex items-center space-x-2">
          <Edit3 className="w-4 h-4 text-emerald-400" />
          <span>{t.priceOverrideHeading}</span>
        </h3>
        <p className="text-xs text-slate-400">{t.priceOverrideSubtitle}</p>

        <div className="grid grid-cols-1 sm:grid-cols-4 gap-4 text-xs">
          <div>
            <label className="text-slate-300 font-bold block mb-1">District</label>
            <select
              value={overrideDistrict}
              onChange={(e) => setOverrideDistrict(e.target.value)}
              className="w-full bg-slate-800 border border-slate-700 text-white rounded-xl px-3 py-2.5 font-bold"
            >
              {["Mumbai", "Pune", "Thane", "Palghar", "Nashik", "Nagpur"].map((d) => (
                <option key={d} value={d}>
                  {d}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="text-slate-300 font-bold block mb-1">Category</label>
            <select
              value={overrideCategory}
              onChange={(e) => setOverrideCategory(e.target.value as EwasteCategory)}
              className="w-full bg-slate-800 border border-slate-700 text-white rounded-xl px-3 py-2.5 font-bold"
            >
              {["PCB", "Cables", "Batteries", "LCD", "Motors_Magnets", "CRT", "Mixed_Plastics"].map(
                (c) => (
                  <option key={c} value={c}>
                    {c}
                  </option>
                )
              )}
            </select>
          </div>

          <div>
            <label className="text-slate-300 font-bold block mb-1">New Buying Rate (₹/kg)</label>
            <input
              type="number"
              required
              value={newRate}
              onChange={(e) => setNewRate(e.target.value)}
              data-testid="input-override-price"
              className="w-full bg-slate-800 border border-slate-700 text-white rounded-xl px-3 py-2.5 font-bold"
            />
          </div>

          <div className="flex items-end">
            <button
              type="submit"
              data-testid="btn-apply-price-override"
              className="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-extrabold py-2.5 px-4 rounded-xl shadow transition text-xs"
            >
              Apply Price Override
            </button>
          </div>
        </div>
      </form>

      {/* Active Price Board Table */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
        <div className="px-6 py-4 border-b border-slate-800 flex justify-between items-center">
          <h3 className="font-extrabold text-white text-sm">
            Active Regional Benchmark Prices (Maharashtra)
          </h3>
          <span className="text-xs text-slate-400">Rolling 7d/30d Median Feed</span>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-slate-300">
            <thead className="bg-slate-800/70 text-slate-400 font-bold uppercase tracking-wider text-[10px]">
              <tr>
                <th className="px-6 py-3.5">District</th>
                <th className="px-6 py-3.5">Category</th>
                <th className="px-6 py-3.5">Govt Rate (₹/kg)</th>
                <th className="px-6 py-3.5">Market Bounds</th>
                <th className="px-6 py-3.5">7-Day Trend</th>
                <th className="px-6 py-3.5">Confidence</th>
                <th className="px-6 py-3.5">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800 font-medium">
              {prices.map((p, idx) => (
                <tr key={idx} className="hover:bg-slate-800/40">
                  <td className="px-6 py-4 font-bold text-white">{p.district}</td>
                  <td className="px-6 py-4 font-bold text-emerald-400">{p.category}</td>
                  <td className="px-6 py-4 text-base font-black text-white">
                    ₹{p.buyingPrice}
                  </td>
                  <td className="px-6 py-4 text-slate-400">
                    ₹{p.marketMin} - ₹{p.marketMax}
                  </td>
                  <td className="px-6 py-4">
                    <span
                      className={`inline-flex items-center gap-1 font-bold ${
                        p.trend === "up"
                          ? "text-emerald-400"
                          : p.trend === "down"
                          ? "text-red-400"
                          : "text-slate-400"
                      }`}
                    >
                      {p.trend === "up" ? (
                        <ArrowUpRight className="w-4 h-4" />
                      ) : p.trend === "down" ? (
                        <ArrowDownRight className="w-4 h-4" />
                      ) : (
                        <Minus className="w-4 h-4" />
                      )}
                      {p.percentChange}%
                    </span>
                  </td>
                  <td className="px-6 py-4 uppercase font-bold text-[10px]">
                    <span
                      className={`px-2 py-0.5 rounded-full ${
                        p.confidence === "high"
                          ? "bg-emerald-950 text-emerald-300"
                          : "bg-amber-950 text-amber-300"
                      }`}
                    >
                      {p.confidence}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    {p.isOverridden ? (
                      <span className="text-[10px] font-bold bg-purple-950 text-purple-300 border border-purple-800 px-2 py-0.5 rounded">
                        Admin Override
                      </span>
                    ) : (
                      <span className="text-slate-500 text-[10px]">System Median</span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
