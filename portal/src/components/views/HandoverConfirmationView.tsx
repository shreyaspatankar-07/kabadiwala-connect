"use client";

import React, { useState } from "react";
import { useLanguage } from "../../context/LanguageContext";
import { mockHandoverRecords } from "../../lib/api";
import { HandoverRecord } from "../../lib/types";
import {
  QrCode,
  AlertTriangle,
  CheckCircle2,
  Scale,
  IndianRupee,
  Receipt,
  FileCheck2,
  Upload,
} from "lucide-react";

export function HandoverConfirmationView() {
  const { t } = useLanguage();
  const [handoverCode, setHandoverCode] = useState("H6-K9P2");
  const [estimatedWeight, setEstimatedWeight] = useState(12.5);
  const [category, setCategory] = useState("PCB");
  const [collectorId, setCollectorId] = useState("KC-C-4921");
  const [measuredWeight, setMeasuredWeight] = useState("12.3");
  const [finalPrice, setFinalPrice] = useState("5166");
  const [paymentMethod, setPaymentMethod] = useState<"cash_received" | "digital_paid">("cash_received");
  const [records, setRecords] = useState<HandoverRecord[]>(mockHandoverRecords);
  const [submittedRecord, setSubmittedRecord] = useState<HandoverRecord | null>(null);

  const measuredNum = parseFloat(measuredWeight) || 0;
  const priceNum = parseFloat(finalPrice) || 0;

  // Weight mismatch calculation: abs(measured - estimated) / estimated * 100
  const mismatchPercent =
    estimatedWeight > 0
      ? Math.abs(measuredNum - estimatedWeight) / estimatedWeight * 100
      : 0;

  const isMismatchExceeded = mismatchPercent > 10.0;

  const handleConfirm = (e: React.FormEvent) => {
    e.preventDefault();
    const newRecord: HandoverRecord = {
      handoverRefNo: handoverCode.toUpperCase().trim(),
      lotId: `KC-MH-2609-${handoverCode.toUpperCase().replace(/[^A-Z0-9]/g, "")}`,
      collectorRefId: collectorId,
      category: category as any,
      collectorWeightKg: estimatedWeight,
      measuredWeightKg: measuredNum,
      weightMismatchPercent: parseFloat(mismatchPercent.toFixed(1)),
      finalPrice: priceNum,
      paymentMethod,
      paymentStatus: isMismatchExceeded ? "disputed" : paymentMethod,
      confirmedAt: new Date().toISOString(),
      recordHash: `hash-${Date.now()}-${Math.random().toString(36).substring(2, 8)}`,
      downstreamStatus: "received",
    };

    setRecords((prev) => [newRecord, ...prev]);
    setSubmittedRecord(newRecord);
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-extrabold text-white">{t.navHandover}</h1>
        <p className="text-xs text-slate-400 mt-1">
          Verify digital handover, record scale weight, and generate immutable EPR proof
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Left Form: Handover Entry & Verification */}
        <div className="lg:col-span-7 bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl space-y-6">
          <form onSubmit={handleConfirm} className="space-y-5">
            {/* 6-Char Code / QR Input */}
            <div className="space-y-2">
              <label className="text-xs font-bold text-slate-300 block">
                {t.qrOrCodePrompt}
              </label>
              <div className="flex gap-2">
                <div className="relative flex-1">
                  <QrCode className="w-5 h-5 text-emerald-400 absolute left-3 top-3" />
                  <input
                    type="text"
                    required
                    maxLength={10}
                    value={handoverCode}
                    onChange={(e) => setHandoverCode(e.target.value.toUpperCase())}
                    placeholder="e.g. H6-K9P2"
                    data-testid="input-handover-code"
                    className="w-full bg-slate-800 border border-slate-700 rounded-xl pl-10 pr-4 py-2.5 text-white font-mono font-bold tracking-widest uppercase focus:outline-none focus:border-emerald-500"
                  />
                </div>
                <button
                  type="button"
                  className="px-3 bg-slate-800 hover:bg-slate-700 border border-slate-700 text-slate-300 rounded-xl text-xs font-bold flex items-center gap-1"
                  title="Simulate QR File Scan"
                  onClick={() => {
                    setHandoverCode("H6-K9P2");
                    setEstimatedWeight(12.5);
                    setCategory("PCB");
                    setCollectorId("KC-C-4921");
                  }}
                >
                  <Upload className="w-4 h-4 text-emerald-400" />
                  <span className="hidden sm:inline">QR Scan</span>
                </button>
              </div>
            </div>

            {/* Collector Estimated Details Summary */}
            <div className="bg-slate-800/80 rounded-xl p-3 border border-slate-700/80 grid grid-cols-3 gap-2 text-center text-xs">
              <div>
                <span className="text-slate-400 block text-[10px] font-bold">CATEGORY</span>
                <span className="font-extrabold text-white">{category}</span>
              </div>
              <div>
                <span className="text-slate-400 block text-[10px] font-bold">EST. WEIGHT</span>
                <span className="font-extrabold text-emerald-400">{estimatedWeight} kg</span>
              </div>
              <div>
                <span className="text-slate-400 block text-[10px] font-bold">COLLECTOR ID</span>
                <span className="font-mono font-bold text-slate-300">{collectorId}</span>
              </div>
            </div>

            {/* Measured Scale Weight & Final Price */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="space-y-2">
                <label className="text-xs font-bold text-slate-300 block">
                  {t.measuredWeightLabel}
                </label>
                <div className="relative">
                  <Scale className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
                  <input
                    type="number"
                    step="0.1"
                    required
                    value={measuredWeight}
                    onChange={(e) => setMeasuredWeight(e.target.value)}
                    data-testid="input-measured-weight"
                    className="w-full bg-slate-800 border border-slate-700 rounded-xl pl-9 pr-4 py-2.5 text-white font-bold focus:outline-none focus:border-emerald-500"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-xs font-bold text-slate-300 block">
                  {t.finalPriceLabel}
                </label>
                <div className="relative">
                  <IndianRupee className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
                  <input
                    type="number"
                    required
                    value={finalPrice}
                    onChange={(e) => setFinalPrice(e.target.value)}
                    data-testid="input-final-price"
                    className="w-full bg-slate-800 border border-slate-700 rounded-xl pl-9 pr-4 py-2.5 text-white font-bold focus:outline-none focus:border-emerald-500"
                  />
                </div>
              </div>
            </div>

            {/* Weight Mismatch Warning Banner */}
            {isMismatchExceeded && (
              <div
                data-testid="weight-mismatch-warning"
                className="bg-red-950/90 border border-red-600/80 rounded-xl p-4 text-red-200 text-xs space-y-1 animate-pulse"
              >
                <div className="flex items-center space-x-2 font-bold text-sm text-red-400">
                  <AlertTriangle className="w-4 h-4 flex-shrink-0" />
                  <span>Weight Mismatch Warning ({mismatchPercent.toFixed(1)}%)</span>
                </div>
                <p>{t.weightMismatchWarning}</p>
              </div>
            )}

            {/* Payment Method */}
            <div className="space-y-2">
              <label className="text-xs font-bold text-slate-300 block">
                {t.paymentMethodLabel}
              </label>
              <div className="grid grid-cols-2 gap-3">
                <button
                  type="button"
                  onClick={() => setPaymentMethod("cash_received")}
                  className={`p-3 rounded-xl border text-xs font-bold flex items-center justify-center space-x-2 transition ${
                    paymentMethod === "cash_received"
                      ? "bg-emerald-600 text-white border-emerald-500 shadow-md"
                      : "bg-slate-800 text-slate-300 border-slate-700 hover:bg-slate-750"
                  }`}
                >
                  <IndianRupee className="w-4 h-4" />
                  <span>Cash Handed Over (रोख दिले)</span>
                </button>

                <button
                  type="button"
                  onClick={() => setPaymentMethod("digital_paid")}
                  className={`p-3 rounded-xl border text-xs font-bold flex items-center justify-center space-x-2 transition ${
                    paymentMethod === "digital_paid"
                      ? "bg-blue-600 text-white border-blue-500 shadow-md"
                      : "bg-slate-800 text-slate-300 border-slate-700 hover:bg-slate-750"
                  }`}
                >
                  <QrCode className="w-4 h-4" />
                  <span>UPI Payment (डिजिटल)</span>
                </button>
              </div>
            </div>

            {/* Submit Confirmation Button */}
            <button
              type="submit"
              data-testid="btn-confirm-handover"
              className="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-extrabold py-3.5 rounded-xl shadow-lg shadow-emerald-900/50 flex items-center justify-center space-x-2 transition"
            >
              <CheckCircle2 className="w-5 h-5" />
              <span>{t.btnConfirmHandover}</span>
            </button>
          </form>
        </div>

        {/* Right Panel: Digital Confirmation Receipt */}
        <div className="lg:col-span-5 bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl flex flex-col justify-between">
          <div>
            <div className="flex items-center space-x-2 text-emerald-400 mb-4">
              <Receipt className="w-5 h-5" />
              <h3 className="font-extrabold text-white text-base">
                EPR Traceability Proof Card
              </h3>
            </div>

            {submittedRecord ? (
              <div className="bg-slate-950 border border-slate-800 rounded-xl p-4 space-y-3 font-mono text-xs text-slate-300">
                <div className="flex justify-between border-b border-slate-800 pb-2">
                  <span className="text-slate-500">REF NO:</span>
                  <span className="text-emerald-400 font-bold">{submittedRecord.handoverRefNo}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">CATEGORY:</span>
                  <span className="text-white font-bold">{submittedRecord.category}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">SCALE WEIGHT:</span>
                  <span className="text-emerald-400 font-bold">{submittedRecord.measuredWeightKg} kg</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">FINAL PAYOUT:</span>
                  <span className="text-emerald-400 font-bold">₹{submittedRecord.finalPrice.toLocaleString()}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">STATUS:</span>
                  <span className="text-emerald-300 uppercase">{submittedRecord.paymentStatus}</span>
                </div>
                <div className="pt-2 border-t border-slate-800">
                  <span className="text-slate-500 block text-[10px]">RECORD HASH CHAIN:</span>
                  <span className="text-[10px] text-slate-400 break-all">{submittedRecord.recordHash}</span>
                </div>
              </div>
            ) : (
              <div className="bg-slate-950/60 border border-dashed border-slate-800 rounded-xl p-8 text-center text-slate-500 space-y-2">
                <FileCheck2 className="w-8 h-8 mx-auto text-slate-600" />
                <p className="text-xs">
                  Fill in the measured scale weight and confirm handover to preview the verified receipt.
                </p>
              </div>
            )}
          </div>

          <div className="mt-6 pt-4 border-t border-slate-800 text-[11px] text-slate-500">
            Complies with CPCB E-Waste (Management) Rules 2022 digital traceability standards.
          </div>
        </div>
      </div>
    </div>
  );
}
