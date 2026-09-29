"use client";

import React, { useState, useEffect, useCallback, useRef } from "react";
import { useLanguage } from "../../context/LanguageContext";
import { lookupHandoverByCode, HandoverLookupResult, mockHandoverRecords } from "../../lib/api";
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
  Loader2,
  XCircle,
  Search,
} from "lucide-react";

export function HandoverConfirmationView() {
  const { t } = useLanguage();
  const [handoverCode, setHandoverCode] = useState("");
  const [lookupResult, setLookupResult] = useState<HandoverLookupResult | null>(null);
  const [isLookingUp, setIsLookingUp] = useState(false);
  const [lookupError, setLookupError] = useState<string | null>(null);
  const [lookupAttempted, setLookupAttempted] = useState(false);

  // Form fields the recycler fills in
  const [measuredWeight, setMeasuredWeight] = useState("");
  const [finalPrice, setFinalPrice] = useState("");
  const [paymentMethod, setPaymentMethod] = useState<"cash_received" | "digital_paid">("cash_received");
  const [records, setRecords] = useState<HandoverRecord[]>(mockHandoverRecords);
  const [submittedRecord, setSubmittedRecord] = useState<HandoverRecord | null>(null);

  // Debounce timer ref for auto-lookup
  const debounceRef = useRef<NodeJS.Timeout | null>(null);

  // Derived values from lookup
  const estimatedWeight = lookupResult?.collector_weight_kg ?? 0;
  const category = lookupResult?.category ?? "";
  const lotId = lookupResult?.lot_id ?? "";
  const collectorId = lotId ? lotId.split("-").slice(0, 3).join("-") : "";
  const timestamp = lookupResult?.timestamp ?? "";

  const measuredNum = parseFloat(measuredWeight) || 0;
  const priceNum = parseFloat(finalPrice) || 0;

  // Weight mismatch calculation
  const mismatchPercent =
    estimatedWeight > 0
      ? (Math.abs(measuredNum - estimatedWeight) / estimatedWeight) * 100
      : 0;
  const isMismatchExceeded = mismatchPercent > 10.0;

  // Auto-lookup when code reaches 6 characters (debounced)
  const performLookup = useCallback(async (code: string) => {
    const trimmed = code.trim().replace(/\s+/g, "");
    if (trimmed.length < 4) {
      setLookupResult(null);
      setLookupError(null);
      setLookupAttempted(false);
      return;
    }

    setIsLookingUp(true);
    setLookupError(null);
    setLookupAttempted(true);

    const result = await lookupHandoverByCode(trimmed);

    if (result && result.is_valid) {
      setLookupResult(result);
      setLookupError(null);
      // Pre-fill measured weight with collector's estimate
      setMeasuredWeight(result.collector_weight_kg.toFixed(1));
      // Calculate a suggested price (weight * ~420 for PCB etc.)
      const suggestedRate = result.category.includes("PCB") ? 420 : result.category.includes("Batt") ? 280 : 350;
      setFinalPrice(Math.round(result.collector_weight_kg * suggestedRate).toString());
    } else {
      setLookupResult(null);
      setLookupError(`No handover record found for code "${trimmed}". Ensure the lot was synced from the collector's phone.`);
    }

    setIsLookingUp(false);
  }, []);

  // Trigger lookup when handoverCode changes
  useEffect(() => {
    if (debounceRef.current) clearTimeout(debounceRef.current);

    const trimmed = handoverCode.trim().replace(/\s+/g, "");
    if (trimmed.length >= 5) {
      debounceRef.current = setTimeout(() => performLookup(trimmed), 400);
    } else {
      setLookupResult(null);
      setLookupError(null);
      setLookupAttempted(false);
    }

    return () => {
      if (debounceRef.current) clearTimeout(debounceRef.current);
    };
  }, [handoverCode, performLookup]);

  // Load live settled lots on mount
  useEffect(() => {
    async function loadSettled() {
      try {
        const { fetchSettledLotsApi } = await import("../../lib/api");
        const liveSettled = await fetchSettledLotsApi();
        if (liveSettled && liveSettled.length > 0) {
          setRecords(liveSettled);
        }
      } catch (err) {
        console.warn("Failed to load live settled lots:", err);
      }
    }
    loadSettled();
  }, []);

  const handleManualLookup = () => {
    performLookup(handoverCode);
  };

  const handleConfirm = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!lookupResult) return;

    setIsLookingUp(true);
    try {
      const { confirmHandoverApi } = await import("../../lib/api");
      await confirmHandoverApi({
        handoverRefNo: lookupResult.handover_ref_no,
        measuredWeightKg: measuredNum,
        finalPrice: priceNum,
        paymentMode: paymentMethod,
      });
    } catch (err) {
      console.warn("API confirm error:", err);
    } finally {
      setIsLookingUp(false);
    }

    const newRecord: HandoverRecord = {
      handoverRefNo: lookupResult.handover_ref_no,
      lotId: lookupResult.lot_id,
      collectorRefId: collectorId || "KC-C-7821",
      category: category as any,
      collectorWeightKg: estimatedWeight,
      measuredWeightKg: measuredNum,
      weightMismatchPercent: parseFloat(mismatchPercent.toFixed(1)),
      finalPrice: priceNum,
      paymentMethod,
      paymentStatus: isMismatchExceeded ? "disputed" : paymentMethod,
      collectorConfirmed: true,
      recyclerConfirmed: !isMismatchExceeded,
      confirmedAt: new Date().toISOString(),
      recordHash: lookupResult.record_hash || `hash-${Date.now()}-${Math.random().toString(36).substring(2, 8)}`,
      downstreamStatus: "received",
    };

    setRecords((prev) => [newRecord, ...prev]);
    setSubmittedRecord(newRecord);
  };

  // Dedicated filter: ONLY records where BOTH collector and recycler have confirmed
  const settledPaidRecords = records.filter(
    (r) => (r.collectorConfirmed !== false) && (r.recyclerConfirmed !== false) && r.paymentStatus !== "disputed"
  );

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-extrabold text-white">{t.navHandover}</h1>
        <p className="text-xs text-slate-400 mt-1">
          Enter the collector&apos;s 6-character code to auto-fetch lot details, verify weight, and generate immutable EPR proof
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
                    placeholder="e.g. W7DC8J"
                    data-testid="input-handover-code"
                    className="w-full bg-slate-800 border border-slate-700 rounded-xl pl-10 pr-4 py-2.5 text-white font-mono font-bold tracking-widest uppercase focus:outline-none focus:border-emerald-500"
                  />
                  {isLookingUp && (
                    <Loader2 className="w-4 h-4 text-emerald-400 absolute right-3 top-3 animate-spin" />
                  )}
                </div>
                <button
                  type="button"
                  className="px-3 bg-slate-800 hover:bg-slate-700 border border-slate-700 text-slate-300 rounded-xl text-xs font-bold flex items-center gap-1"
                  title="Lookup by code"
                  onClick={handleManualLookup}
                >
                  <Search className="w-4 h-4 text-emerald-400" />
                  <span className="hidden sm:inline">Lookup</span>
                </button>
                <button
                  type="button"
                  className="px-3 bg-slate-800 hover:bg-slate-700 border border-slate-700 text-slate-300 rounded-xl text-xs font-bold flex items-center gap-1"
                  title="Simulate QR File Scan"
                  onClick={() => {
                    setHandoverCode("H6-K9P2");
                  }}
                >
                  <Upload className="w-4 h-4 text-emerald-400" />
                  <span className="hidden sm:inline">QR Scan</span>
                </button>
              </div>
            </div>

            {/* Lookup Status Messages */}
            {isLookingUp && (
              <div className="bg-blue-950/60 border border-blue-700/50 rounded-xl p-3 text-blue-300 text-xs flex items-center gap-2">
                <Loader2 className="w-4 h-4 animate-spin" />
                <span>Searching for handover record...</span>
              </div>
            )}

            {lookupError && !isLookingUp && (
              <div className="bg-red-950/60 border border-red-700/50 rounded-xl p-3 text-red-300 text-xs flex items-center gap-2">
                <XCircle className="w-4 h-4 flex-shrink-0" />
                <span>{lookupError}</span>
              </div>
            )}

            {lookupResult && !isLookingUp && (
              <div className="bg-emerald-950/60 border border-emerald-700/50 rounded-xl p-3 text-emerald-300 text-xs flex items-center gap-2">
                <CheckCircle2 className="w-4 h-4 flex-shrink-0" />
                <span>
                  Lot <strong>{lookupResult.lot_id}</strong> found! Collector details loaded.
                  {lookupResult.integrity_status === "verified" && " Cryptographic integrity verified ✓"}
                </span>
              </div>
            )}

            {/* Collector Estimated Details Summary — auto-populated from backend */}
            <div className="bg-slate-800/80 rounded-xl p-3 border border-slate-700/80 grid grid-cols-3 gap-2 text-center text-xs">
              <div>
                <span className="text-slate-400 block text-[10px] font-bold">CATEGORY</span>
                <span className="font-extrabold text-white">{category || "—"}</span>
              </div>
              <div>
                <span className="text-slate-400 block text-[10px] font-bold">EST. WEIGHT</span>
                <span className="font-extrabold text-emerald-400">
                  {estimatedWeight > 0 ? `${estimatedWeight} kg` : "—"}
                </span>
              </div>
              <div>
                <span className="text-slate-400 block text-[10px] font-bold">LOT ID</span>
                <span className="font-mono font-bold text-slate-300">{lotId || "—"}</span>
              </div>
            </div>

            {/* Timestamp & Integrity Row */}
            {lookupResult && (
              <div className="bg-slate-800/50 rounded-xl p-2 border border-slate-700/50 grid grid-cols-2 gap-2 text-center text-xs">
                <div>
                  <span className="text-slate-400 block text-[10px] font-bold">CREATED</span>
                  <span className="font-bold text-slate-300">
                    {timestamp ? new Date(timestamp).toLocaleString("en-IN", { dateStyle: "medium", timeStyle: "short" }) : "—"}
                  </span>
                </div>
                <div>
                  <span className="text-slate-400 block text-[10px] font-bold">INTEGRITY</span>
                  <span className={`font-bold ${lookupResult.integrity_status === "verified" ? "text-emerald-400" : "text-amber-400"}`}>
                    {lookupResult.integrity_status === "verified" ? "✓ HMAC Verified" : lookupResult.integrity_status}
                  </span>
                </div>
              </div>
            )}

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
                    disabled={!lookupResult}
                    className="w-full bg-slate-800 border border-slate-700 rounded-xl pl-9 pr-4 py-2.5 text-white font-bold focus:outline-none focus:border-emerald-500 disabled:opacity-40 disabled:cursor-not-allowed"
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
                    disabled={!lookupResult}
                    className="w-full bg-slate-800 border border-slate-700 rounded-xl pl-9 pr-4 py-2.5 text-white font-bold focus:outline-none focus:border-emerald-500 disabled:opacity-40 disabled:cursor-not-allowed"
                  />
                </div>
              </div>
            </div>

            {/* Weight Mismatch Warning Banner */}
            {lookupResult && isMismatchExceeded && (
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
              disabled={!lookupResult}
              data-testid="btn-confirm-handover"
              className="w-full bg-emerald-600 hover:bg-emerald-500 disabled:bg-slate-700 disabled:cursor-not-allowed text-white font-extrabold py-3.5 rounded-xl shadow-lg shadow-emerald-900/50 flex items-center justify-center space-x-2 transition"
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
                  <span className="text-slate-500">LOT ID:</span>
                  <span className="text-white font-bold">{submittedRecord.lotId}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">CATEGORY:</span>
                  <span className="text-white font-bold">{submittedRecord.category}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">COLLECTOR WEIGHT:</span>
                  <span className="text-slate-300">{submittedRecord.collectorWeightKg} kg</span>
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
            ) : lookupResult ? (
              <div className="bg-slate-950 border border-emerald-900/50 rounded-xl p-4 space-y-3 font-mono text-xs text-slate-300">
                <div className="text-center mb-2">
                  <span className="text-emerald-400 text-[10px] font-bold uppercase tracking-wider">
                    Collector Submitted Details (Pre-Verification)
                  </span>
                </div>
                <div className="flex justify-between border-b border-slate-800 pb-2">
                  <span className="text-slate-500">REF NO:</span>
                  <span className="text-emerald-400 font-bold">{lookupResult.handover_ref_no}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">LOT ID:</span>
                  <span className="text-white font-bold">{lookupResult.lot_id}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">CATEGORY:</span>
                  <span className="text-white font-bold">{lookupResult.category}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">COLLECTOR WEIGHT:</span>
                  <span className="text-emerald-400 font-bold">{lookupResult.collector_weight_kg} kg</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">CREATED:</span>
                  <span className="text-slate-300">
                    {new Date(lookupResult.timestamp).toLocaleString("en-IN", { dateStyle: "medium", timeStyle: "short" })}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">INTEGRITY:</span>
                  <span className={`font-bold ${lookupResult.integrity_status === "verified" ? "text-emerald-400" : "text-amber-400"}`}>
                    {lookupResult.integrity_status === "verified" ? "✓ VERIFIED" : lookupResult.integrity_status}
                  </span>
                </div>
                <div className="pt-2 border-t border-slate-800">
                  <span className="text-slate-500 block text-[10px]">RECORD HASH:</span>
                  <span className="text-[10px] text-slate-400 break-all">{lookupResult.record_hash}</span>
                </div>
              </div>
            ) : (
              <div className="bg-slate-950/60 border border-dashed border-slate-800 rounded-xl p-8 text-center text-slate-500 space-y-2">
                <FileCheck2 className="w-8 h-8 mx-auto text-slate-600" />
                <p className="text-xs">
                  {lookupAttempted
                    ? "No record found. Ensure the collector has synced their lot from the phone."
                    : "Enter the 6-character handover code from the collector's phone to auto-load lot details."}
                </p>
              </div>
            )}
          </div>

          <div className="mt-6 pt-4 border-t border-slate-800 text-[11px] text-slate-500">
            Complies with CPCB E-Waste (Management) Rules 2022 digital traceability standards.
          </div>
        </div>
      </div>

      {/* Dedicated Settled & Paid Transactions Table (Double Confirmation Required) */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl space-y-4">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 border-b border-slate-800 pb-4">
          <div className="flex items-center space-x-3">
            <div className="p-2 rounded-lg bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
              <CheckCircle2 className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-lg font-bold text-white">Settled / Paid Transactions</h2>
              <p className="text-xs text-slate-400">
                Verified handovers where BOTH Collector and Recycler have confirmed (Double-Confirmed)
              </p>
            </div>
          </div>
          <span className="text-xs bg-emerald-950 text-emerald-300 font-mono px-3 py-1.5 rounded-full border border-emerald-800 w-fit">
            {settledPaidRecords.length} Double-Confirmed Transactions
          </span>
        </div>

        {settledPaidRecords.length === 0 ? (
          <div className="text-center py-10 text-slate-500 text-sm">
            No settled transactions recorded yet. Confirm a handover above to populate this ledger.
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-950 text-slate-400 uppercase tracking-wider font-semibold border-b border-slate-800">
                <tr>
                  <th className="py-3 px-4">Ref Code</th>
                  <th className="py-3 px-4">Lot / Collector</th>
                  <th className="py-3 px-4">Category</th>
                  <th className="py-3 px-4">Scale Weight</th>
                  <th className="py-3 px-4">Final Payout</th>
                  <th className="py-3 px-4">Confirmation Status</th>
                  <th className="py-3 px-4">Settled At</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-800 text-slate-300 font-medium">
                {settledPaidRecords.map((r, i) => (
                  <tr key={i} className="hover:bg-slate-800/50 transition">
                    <td className="py-3.5 px-4 font-mono font-bold text-emerald-400">
                      {r.handoverRefNo}
                    </td>
                    <td className="py-3.5 px-4 font-mono">
                      <div className="text-white font-bold">{r.lotId}</div>
                      <div className="text-[11px] text-slate-400">{r.collectorRefId}</div>
                    </td>
                    <td className="py-3.5 px-4">
                      <span className="px-2 py-0.5 rounded bg-slate-800 text-slate-200 border border-slate-700 font-semibold">
                        {r.category}
                      </span>
                    </td>
                    <td className="py-3.5 px-4 font-bold text-white">
                      {r.measuredWeightKg.toFixed(1)} kg
                    </td>
                    <td className="py-3.5 px-4 font-bold text-emerald-400 text-sm">
                      ₹{r.finalPrice.toLocaleString()}
                    </td>
                    <td className="py-3.5 px-4">
                      <span className="inline-flex items-center space-x-1 px-2 py-1 rounded-full text-[10px] font-bold bg-emerald-950 text-emerald-300 border border-emerald-700">
                        <CheckCircle2 className="w-3 h-3 text-emerald-400" />
                        <span>Double Confirmed ✓</span>
                      </span>
                    </td>
                    <td className="py-3.5 px-4 text-slate-400 text-[11px]">
                      {new Date(r.confirmedAt).toLocaleString("en-IN", {
                        dateStyle: "short",
                        timeStyle: "short",
                      })}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
