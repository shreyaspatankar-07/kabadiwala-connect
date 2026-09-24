import React from "react";
import { ShieldCheck, Truck, BarChart3, WifiOff } from "lucide-react";

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-8 bg-slate-50">
      <div className="max-w-4xl w-full space-y-8">
        <div className="text-center space-y-3">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-100 text-emerald-800 text-sm font-medium">
            <ShieldCheck className="w-4 h-4" />
            E-Waste (Management) Rules 2022 Compliant
          </div>
          <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 sm:text-5xl">
            Kabadiwala Connect
          </h1>
          <p className="text-lg text-slate-600 max-w-2xl mx-auto">
            Authorized Recycler & Admin Oversight Portal bridging informal e-waste collectors
            with certified EPR aggregators.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 pt-6">
          <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm hover:shadow transition">
            <div className="w-12 h-12 bg-emerald-100 text-emerald-700 rounded-lg flex items-center justify-center mb-4">
              <Truck className="w-6 h-6" />
            </div>
            <h3 className="text-lg font-semibold text-slate-800">Recycler Intake</h3>
            <p className="text-sm text-slate-500 mt-2">
              Verify incoming collector lots, confirm scale weights, and issue cryptographic handover receipts.
            </p>
          </div>

          <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm hover:shadow transition">
            <div className="w-12 h-12 bg-blue-100 text-blue-700 rounded-lg flex items-center justify-center mb-4">
              <WifiOff className="w-6 h-6" />
            </div>
            <h3 className="text-lg font-semibold text-slate-800">Offline Sync</h3>
            <p className="text-sm text-slate-500 mt-2">
              Synchronize offline handovers and cash receipts seamlessly once collectors regain cellular data.
            </p>
          </div>

          <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm hover:shadow transition">
            <div className="w-12 h-12 bg-amber-100 text-amber-700 rounded-lg flex items-center justify-center mb-4">
              <BarChart3 className="w-6 h-6" />
            </div>
            <h3 className="text-lg font-semibold text-slate-800">JNARDDC Oversight</h3>
            <p className="text-sm text-slate-500 mt-2">
              Monitor regional price fairness, mass balance reporting, and informal sector formalization.
            </p>
          </div>
        </div>

        <div className="text-center text-xs text-slate-400 pt-8 border-t border-slate-200">
          SIH Problem Statement 26229 • Ministry of Mines / JNARDDC
        </div>
      </div>
    </main>
  );
}
