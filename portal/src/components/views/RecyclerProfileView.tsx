"use client";

import React, { useState } from "react";
import { useLanguage } from "../../context/LanguageContext";
import { mockRecyclerProfile } from "../../lib/api";
import { EwasteCategory, RecyclerProfile } from "../../lib/types";
import {
  FileText,
  Upload,
  CheckCircle2,
  Truck,
  MapPin,
  IndianRupee,
  Save,
  FileCheck,
} from "lucide-react";

const ALL_CATEGORIES: EwasteCategory[] = [
  "PCB",
  "Cables",
  "Batteries",
  "LCD",
  "Motors_Magnets",
  "CRT",
  "Mixed_Plastics",
  "Other",
];

const ALL_DISTRICTS = [
  "Palghar",
  "Thane",
  "Mumbai",
  "Pune",
  "Nashik",
  "Nagpur",
  "Raigad",
  "Aurangabad",
];

export function RecyclerProfileView() {
  const { t } = useLanguage();
  const [profile, setProfile] = useState<RecyclerProfile>(mockRecyclerProfile);
  const [docFileName, setDocFileName] = useState("MPCB_EPR_Authorization_2024.pdf");
  const [saveSuccess, setSaveSuccess] = useState(false);

  const toggleMaterial = (cat: EwasteCategory) => {
    setProfile((prev) => {
      const exists = prev.materialsAccepted.includes(cat);
      const updated = exists
        ? prev.materialsAccepted.filter((c) => c !== cat)
        : [...prev.materialsAccepted, cat];
      return { ...prev, materialsAccepted: updated };
    });
  };

  const toggleDistrict = (dist: string) => {
    setProfile((prev) => {
      const exists = prev.serviceAreaDistricts.includes(dist);
      const updated = exists
        ? prev.serviceAreaDistricts.filter((d) => d !== dist)
        : [...prev.serviceAreaDistricts, dist];
      return { ...prev, serviceAreaDistricts: updated };
    });
  };

  const handleRateChange = (cat: EwasteCategory, val: string) => {
    const num = parseFloat(val) || 0;
    setProfile((prev) => ({
      ...prev,
      offeredRates: {
        ...prev.offeredRates,
        [cat]: num,
      },
    }));
  };

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    setSaveSuccess(true);
    setTimeout(() => setSaveSuccess(false), 4000);
  };

  return (
    <form onSubmit={handleSave} className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-2xl font-extrabold text-white">{t.navProfile}</h1>
          <p className="text-xs text-slate-400 mt-1">
            Manage your EPR authorization documents, accepted materials, service districts, and live rate card
          </p>
        </div>
        <button
          type="submit"
          data-testid="btn-save-profile"
          className="bg-emerald-600 hover:bg-emerald-500 text-white font-extrabold px-6 py-2.5 rounded-xl shadow-lg shadow-emerald-900/40 text-xs flex items-center space-x-2 transition"
        >
          <Save className="w-4 h-4" />
          <span>Save Changes</span>
        </button>
      </div>

      {saveSuccess && (
        <div className="bg-emerald-950/90 border border-emerald-600 text-emerald-200 px-4 py-3 rounded-xl flex items-center space-x-2 text-sm font-semibold">
          <CheckCircle2 className="w-5 h-5 text-emerald-400" />
          <span>Profile, Service Area, and Rate Card updated successfully!</span>
        </div>
      )}

      {/* 1. Authorization Document Upload Reference */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl space-y-4">
        <h3 className="text-base font-extrabold text-white flex items-center space-x-2">
          <FileCheck className="w-5 h-5 text-emerald-400" />
          <span>EPR Authorization Compliance Document</span>
        </h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
          <div>
            <label className="text-slate-400 block font-bold mb-1">Authorization Number</label>
            <input
              type="text"
              readOnly
              value={profile.authorizationNumber}
              className="w-full bg-slate-800 border border-slate-700 rounded-xl px-4 py-2 text-slate-300 font-mono"
            />
          </div>
          <div>
            <label className="text-slate-400 block font-bold mb-1">Upload Renewal / Proof Document</label>
            <div className="flex items-center space-x-2">
              <label className="cursor-pointer bg-slate-800 hover:bg-slate-750 border border-slate-700 text-slate-200 px-4 py-2 rounded-xl flex items-center space-x-2 transition">
                <Upload className="w-4 h-4 text-emerald-400" />
                <span>Upload PDF</span>
                <input
                  type="file"
                  accept=".pdf,.png,.jpg"
                  className="hidden"
                  onChange={(e) => {
                    if (e.target.files?.[0]) {
                      setDocFileName(e.target.files[0].name);
                    }
                  }}
                />
              </label>
              <span className="text-slate-400 font-mono text-xs truncate max-w-xs">
                {docFileName}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* 2. Materials Accepted Checklist */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl space-y-4">
        <h3 className="text-base font-extrabold text-white flex items-center justify-between">
          <span>{t.materialsAccepted}</span>
          <span className="text-xs text-slate-400">
            {profile.materialsAccepted.length} of {ALL_CATEGORIES.length} Selected
          </span>
        </h3>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
          {ALL_CATEGORIES.map((cat) => {
            const isSelected = profile.materialsAccepted.includes(cat);
            return (
              <button
                type="button"
                key={cat}
                onClick={() => toggleMaterial(cat)}
                data-testid={`checkbox-mat-${cat}`}
                className={`p-3 rounded-xl border text-xs font-bold flex items-center space-x-2.5 text-left transition ${
                  isSelected
                    ? "bg-emerald-950 border-emerald-600 text-white"
                    : "bg-slate-800/80 border-slate-700 text-slate-400 hover:bg-slate-800"
                }`}
              >
                <div
                  className={`w-4 h-4 rounded flex items-center justify-center border ${
                    isSelected
                      ? "bg-emerald-600 border-emerald-500 text-white"
                      : "border-slate-600 bg-slate-900"
                  }`}
                >
                  {isSelected && <CheckCircle2 className="w-3.5 h-3.5" />}
                </div>
                <span>{cat}</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* 3. Service Area & Pickup Settings */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl space-y-6">
        <div>
          <h3 className="text-base font-extrabold text-white flex items-center space-x-2 mb-3">
            <MapPin className="w-5 h-5 text-emerald-400" />
            <span>{t.serviceArea}</span>
          </h3>
          <div className="flex flex-wrap gap-2">
            {ALL_DISTRICTS.map((dist) => {
              const isSelected = profile.serviceAreaDistricts.includes(dist);
              return (
                <button
                  type="button"
                  key={dist}
                  onClick={() => toggleDistrict(dist)}
                  className={`px-3 py-1.5 rounded-xl border text-xs font-bold transition ${
                    isSelected
                      ? "bg-blue-950 border-blue-600 text-blue-200"
                      : "bg-slate-800 border-slate-700 text-slate-400 hover:text-white"
                  }`}
                >
                  {dist}
                </button>
              );
            })}
          </div>
        </div>

        <div className="pt-4 border-t border-slate-800 grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div className="flex items-center space-x-3 bg-slate-800/80 p-4 rounded-xl border border-slate-700/80">
            <input
              type="checkbox"
              id="pickupToggle"
              checked={profile.pickupAvailable}
              onChange={(e) =>
                setProfile((prev) => ({ ...prev, pickupAvailable: e.target.checked }))
              }
              className="w-5 h-5 text-emerald-600 rounded bg-slate-900 border-slate-600 focus:ring-0 cursor-pointer"
            />
            <label htmlFor="pickupToggle" className="cursor-pointer text-xs font-bold text-white">
              {t.pickupAvailable}
            </label>
          </div>

          <div className="bg-slate-800/80 p-4 rounded-xl border border-slate-700/80 flex items-center space-x-3">
            <Truck className="w-5 h-5 text-slate-400" />
            <div className="flex-1">
              <label className="text-slate-400 block text-[10px] font-bold">
                {t.pickupRadius}
              </label>
              <input
                type="number"
                value={profile.pickupRadiusKm}
                onChange={(e) =>
                  setProfile((prev) => ({
                    ...prev,
                    pickupRadiusKm: parseFloat(e.target.value) || 0,
                  }))
                }
                className="w-full bg-slate-900 border border-slate-700 rounded-lg px-3 py-1 text-white font-bold text-xs"
              />
            </div>
          </div>
        </div>
      </div>

      {/* 4. Quick Rate Card Editor */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl space-y-4">
        <h3 className="text-base font-extrabold text-white flex items-center space-x-2">
          <IndianRupee className="w-5 h-5 text-emerald-400" />
          <span>{t.quickRateCard}</span>
        </h3>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
          {ALL_CATEGORIES.map((cat) => (
            <div key={cat} className="bg-slate-800/80 rounded-xl p-3 border border-slate-700/80 space-y-1">
              <label className="text-[11px] font-bold text-slate-400 block truncate">
                {cat}
              </label>
              <div className="relative">
                <span className="text-slate-500 text-xs absolute left-2.5 top-2 font-bold">₹</span>
                <input
                  type="number"
                  step="1"
                  value={profile.offeredRates[cat] || 0}
                  onChange={(e) => handleRateChange(cat, e.target.value)}
                  data-testid={`input-rate-${cat}`}
                  className="w-full bg-slate-900 border border-slate-700 rounded-lg pl-6 pr-3 py-1.5 text-white font-black text-sm focus:outline-none focus:border-emerald-500"
                />
              </div>
            </div>
          ))}
        </div>
      </div>
    </form>
  );
}
