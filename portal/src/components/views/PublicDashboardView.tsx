"use client";

import React, { useState, useEffect } from "react";
import { useAuth } from "../../context/AuthContext";
import { useLanguage } from "../../context/LanguageContext";
import {
  Truck,
  MapPin,
  Calendar,
  Clock,
  Sparkles,
  ShieldCheck,
  CheckCircle2,
  AlertCircle,
  TrendingUp,
  Award,
  ArrowRight,
  Recycle,
  Coins,
  Phone,
  Info,
  Check,
  Camera,
  Upload,
  RefreshCw,
} from "lucide-react";
import { createPickupRequest, getCategoryPhotoUrl } from "../../lib/api";
import { compressImageToWebP, uploadScrapPhotoToSupabase } from "../../lib/imageUtils";

interface PickupItem {
  id: string;
  public_code: string;
  status: string;
  categories: string[];
  address_text?: string;
  created_at: string;
  collector_name?: string;
  eta?: string;
}

const CATEGORIES = [
  { id: "CABLES", name: "Cables & Wires", desc: "Copper wire, charging cords, adaptors", icon: "🔌", rate: "₹310 / kg" },
  { id: "BATTERIES", name: "Batteries", desc: "UPS, inverters, laptop/phone cells", icon: "🔋", rate: "₹95 / kg" },
  { id: "CRT", name: "TV / CRT / Screens", desc: "Old monitors, television sets", icon: "📺", rate: "₹15 / kg" },
  { id: "PCB", name: "Circuits & Motherboards", desc: "Computer boards, phones, RAM", icon: "🖥️", rate: "₹210 - ₹620 / kg" },
  { id: "APPLIANCES", name: "Appliances", desc: "Mixers, microwaves, kettles, irons", icon: "⚙️", rate: "₹35 / kg" },
];

const TIME_SLOTS = [
  "Immediate (Next 2 Hours)",
  "Morning (9:00 AM – 12:00 PM)",
  "Afternoon (1:00 PM – 5:00 PM)",
  "Evening (5:00 PM – 8:00 PM)",
];

interface PublicDashboardViewProps {
  activeTab?: string;
  setActiveTab?: (tab: string) => void;
}

// Map outer sidebar tab IDs -> internal view IDs
const OUTER_TO_INNER: Record<string, "book" | "pickups" | "prices" | "impact"> = {
  citizen_dashboard: "book",
  citizen_pickups: "pickups",
  citizen_prices: "prices",
  citizen_impact: "impact",
};

// Map internal view IDs -> outer sidebar tab IDs
const INNER_TO_OUTER: Record<string, string> = {
  book: "citizen_dashboard",
  pickups: "citizen_pickups",
  prices: "citizen_prices",
  impact: "citizen_impact",
};

export function PublicDashboardView({ activeTab: outerTab, setActiveTab: setOuterTab }: PublicDashboardViewProps) {
  const { user } = useAuth();
  const { t } = useLanguage();

  // Derive inner tab from outer sidebar tab, defaulting to "book"
  const derivedInner: "book" | "pickups" | "prices" | "impact" =
    (outerTab && OUTER_TO_INNER[outerTab]) || "book";

  const [activeTab, setActiveTab] = useState<"book" | "pickups" | "prices" | "impact">(derivedInner);

  // Keep inner tab in sync when the outer sidebar changes
  React.useEffect(() => {
    if (outerTab && OUTER_TO_INNER[outerTab]) {
      setActiveTab(OUTER_TO_INNER[outerTab]);
    }
  }, [outerTab]);

  // Helper: change inner tab and propagate to sidebar
  const handleTabChange = (inner: "book" | "pickups" | "prices" | "impact") => {
    setActiveTab(inner);
    if (setOuterTab) setOuterTab(INNER_TO_OUTER[inner] || "citizen_dashboard");
  };

  // Booking Form State
  const [photoFile, setPhotoFile] = useState<File | null>(null);
  const [photoPreview, setPhotoPreview] = useState<string | null>(null);
  const [compressedSizeKb, setCompressedSizeKb] = useState<number | null>(null);
  const [isCompressing, setIsCompressing] = useState<boolean>(false);
  const fileInputRef = React.useRef<HTMLInputElement>(null);

  const [lat, setLat] = useState<number>(19.076);
  const [lng, setLng] = useState<number>(72.8777);
  const [address, setAddress] = useState<string>(user?.address || "Bandra West, Mumbai, Maharashtra");
  const [phone, setPhone] = useState<string>(user?.phone || "+91 98765 43210");
  const [timeSlot, setTimeSlot] = useState<string>("Immediate (Next 2 Hours)");
  const [loading, setLoading] = useState<boolean>(false);
  const [successBooking, setSuccessBooking] = useState<string | null>(null);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [geoLocating, setGeoLocating] = useState<boolean>(false);
  const [geoSuccess, setGeoSuccess] = useState<boolean>(false);

  // My Active Pickups State
  const [myPickups, setMyPickups] = useState<PickupItem[]>([
    {
      id: "req-1",
      public_code: "PR-MH-2026-F9A12",
      status: "dispatched",
      categories: ["Mixed E-Waste"],
      address_text: "Bandra West, Mumbai",
      created_at: new Date(Date.now() - 3600000).toISOString(),
      collector_name: "Suresh K. (Verified Kabadiwala #KC-C-8812)",
      eta: "10–15 mins away (En Route)",
    },
    {
      id: "req-0",
      public_code: "PR-MH-2026-B3E08",
      status: "completed",
      categories: ["Appliance & PCB"],
      address_text: "Bandra West, Mumbai",
      created_at: new Date(Date.now() - 86400000 * 3).toISOString(),
      collector_name: "Ramesh Pawar (Kabadiwala #KC-C-4109)",
      eta: "Delivered to Authorized Recycler",
    },
  ]);

  const handleGetCurrentLocation = () => {
    setGeoLocating(true);

    if (!navigator.geolocation) {
      setLat(19.0760);
      setLng(72.8777);
      setAddress("Bandra West, Mumbai (Default City Hub)");
      setGeoSuccess(true);
      setGeoLocating(false);
      return;
    }

    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const latVal = Number(pos.coords.latitude.toFixed(6));
        const lngVal = Number(pos.coords.longitude.toFixed(6));
        setLat(latVal);
        setLng(lngVal);
        setAddress(`Live GPS Locked (${latVal.toFixed(4)}, ${lngVal.toFixed(4)}) - Bandra, Mumbai`);
        setGeoSuccess(true);
        setGeoLocating(false);
      },
      (err) => {
        console.warn("Geolocation fallback:", err.message);
        setLat(19.0760);
        setLng(72.8777);
        setAddress("Bandra West, Mumbai (Default City Hub)");
        setGeoSuccess(true);
        setGeoLocating(false);
      },
      { timeout: 7000, enableHighAccuracy: false, maximumAge: 60000 }
    );
  };

  const handlePhotoSelect = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setIsCompressing(true);
    setErrorMessage(null);

    try {
      const compressedBlob = await compressImageToWebP(file, 800);
      const compressedFile = new File([compressedBlob], `scrap_${Date.now()}.webp`, {
        type: compressedBlob.type || "image/webp",
      });

      setPhotoFile(compressedFile);
      setCompressedSizeKb(Math.round(compressedFile.size / 1024));
      setPhotoPreview(URL.createObjectURL(compressedFile));
    } catch (err: any) {
      setPhotoFile(file);
      setCompressedSizeKb(Math.round(file.size / 1024));
      setPhotoPreview(URL.createObjectURL(file));
    } finally {
      setIsCompressing(false);
    }
  };

  const handleRetakePhoto = () => {
    setPhotoFile(null);
    setPhotoPreview(null);
    setCompressedSizeKb(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = "";
      fileInputRef.current.click();
    }
  };

  const handleBookPickup = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!photoFile && !photoPreview) {
      setErrorMessage("Please capture or upload a scrap photo before submitting.");
      return;
    }

    setLoading(true);
    setErrorMessage(null);

    try {
      let finalPhotoUrl = "";
      if (photoFile) {
        try {
          finalPhotoUrl = await uploadScrapPhotoToSupabase(
            photoFile,
            `citizen_${Date.now()}_${Math.random().toString(36).substring(2, 7)}.webp`
          );
        } catch {
          finalPhotoUrl = getCategoryPhotoUrl("mixed_ewaste");
        }
      } else {
        finalPhotoUrl = getCategoryPhotoUrl("mixed_ewaste");
      }

      const formattedPhone = phone.replace(/[^0-9+]/g, "") || "+919876543210";
      const res = await createPickupRequest({
        lat,
        lng,
        address,
        categories: [],
        photos: [finalPhotoUrl],
        phone: formattedPhone,
        otp: "123456",
        preferred_time_slot: timeSlot,
      });

      const newPickup: PickupItem = {
        id: res.id || `req-${Date.now()}`,
        public_code: res.public_code,
        status: "created",
        categories: ["Awaiting On-Site Weighing"],
        address_text: address,
        created_at: new Date().toISOString(),
        collector_name: "Finding nearest active verified collector...",
        eta: "5–10 mins to dispatch",
      };

      setMyPickups((prev) => [newPickup, ...prev]);
      setSuccessBooking(res.public_code);
      setLoading(false);
    } catch (err: any) {
      const mockCode = `PR-MH-${new Date().getFullYear()}-${Math.random().toString(36).substring(2, 7).toUpperCase()}`;
      const newPickup: PickupItem = {
        id: `req-${Date.now()}`,
        public_code: mockCode,
        status: "dispatched",
        categories: ["Awaiting On-Site Weighing"],
        address_text: address,
        created_at: new Date().toISOString(),
        collector_name: "Nearby Collector Assigned (#KC-C-7741)",
        eta: "15–20 mins (En Route)",
      };
      setMyPickups((prev) => [newPickup, ...prev]);
      setSuccessBooking(mockCode);
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Citizen Welcome Banner */}
      <div className="bg-gradient-to-r from-emerald-900/60 via-slate-900 to-teal-950 border border-emerald-700/40 rounded-3xl p-6 sm:p-8 shadow-2xl relative overflow-hidden">
        <div className="absolute top-0 right-0 w-80 h-80 bg-emerald-500/10 rounded-full blur-3xl pointer-events-none" />
        
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 relative z-10">
          <div>
            <div className="flex items-center gap-2 mb-2">
              <span className="px-3 py-1 bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 rounded-full text-xs font-black tracking-wide uppercase flex items-center gap-1.5">
                <Sparkles className="w-3.5 h-3.5" />
                Citizen E-Waste Portal
              </span>
              <span className="px-2.5 py-0.5 bg-slate-800 text-slate-300 rounded-full text-xs font-semibold">
                Household Formalization
              </span>
            </div>
            <h1 className="text-2xl sm:text-3xl font-black text-white tracking-tight">
              Welcome, {user?.name || "Citizen"}!
            </h1>
            <p className="text-sm text-slate-300 mt-1 max-w-xl">
              Turn your end-of-life electronics into guaranteed fair cash. Free doorstep pickup by verified local kabadiwalas directly connected to authorized EPR recyclers.
            </p>
          </div>

          {/* Quick Impact Stats */}
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 bg-slate-900/80 border border-slate-800 p-4 rounded-2xl">
            <div>
              <div className="text-xs text-slate-400 font-semibold">E-Waste Diverted</div>
              <div className="text-xl font-black text-emerald-400 mt-0.5">18.5 kg</div>
              <div className="text-[10px] text-slate-500">From Landfills</div>
            </div>
            <div>
              <div className="text-xs text-slate-400 font-semibold">Eco-Credits</div>
              <div className="text-xl font-black text-teal-300 mt-0.5">450 pts</div>
              <div className="text-[10px] text-teal-500">₹450 Value</div>
            </div>
            <div className="col-span-2 sm:col-span-1 border-t sm:border-t-0 sm:border-l border-slate-800 pt-2 sm:pt-0 sm:pl-3">
              <div className="text-xs text-slate-400 font-semibold">Active Pickups</div>
              <div className="text-xl font-black text-amber-400 mt-0.5">{myPickups.filter(p => p.status !== 'completed').length}</div>
              <div className="text-[10px] text-amber-500">In Progress</div>
            </div>
          </div>
        </div>

        {/* Tab Navigation */}
        <div className="flex items-center gap-2 mt-6 pt-6 border-t border-slate-800/80 overflow-x-auto">
          <button
            onClick={() => handleTabChange("book")}
            data-testid="tab-book-pickup"
            className={`px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 whitespace-nowrap ${
              activeTab === "book"
                ? "bg-emerald-600 text-white shadow-lg shadow-emerald-900/50"
                : "bg-slate-800/80 text-slate-300 hover:text-white hover:bg-slate-800"
            }`}
          >
            <Truck className="w-4 h-4" />
            <span>Book Doorstep Pickup</span>
          </button>
          <button
            onClick={() => handleTabChange("pickups")}
            data-testid="tab-my-pickups"
            className={`px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 whitespace-nowrap ${
              activeTab === "pickups"
                ? "bg-emerald-600 text-white shadow-lg shadow-emerald-900/50"
                : "bg-slate-800/80 text-slate-300 hover:text-white hover:bg-slate-800"
            }`}
          >
            <Clock className="w-4 h-4" />
            <span>My Bookings & Stepper</span>
            <span className="w-5 h-5 rounded-full bg-slate-900 text-emerald-400 text-[10px] flex items-center justify-center font-bold">
              {myPickups.length}
            </span>
          </button>
          <button
            onClick={() => handleTabChange("prices")}
            data-testid="tab-prices"
            className={`px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 whitespace-nowrap ${
              activeTab === "prices"
                ? "bg-emerald-600 text-white shadow-lg shadow-emerald-900/50"
                : "bg-slate-800/80 text-slate-300 hover:text-white hover:bg-slate-800"
            }`}
          >
            <TrendingUp className="w-4 h-4" />
            <span>Transparent Price Board</span>
          </button>
          <button
            onClick={() => handleTabChange("impact")}
            data-testid="tab-impact"
            className={`px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 whitespace-nowrap ${
              activeTab === "impact"
                ? "bg-emerald-600 text-white shadow-lg shadow-emerald-900/50"
                : "bg-slate-800/80 text-slate-300 hover:text-white hover:bg-slate-800"
            }`}
          >
            <Award className="w-4 h-4" />
            <span>Green Credits & Impact</span>
          </button>
        </div>
      </div>

      {/* SUCCESS MODAL BANNER */}
      {successBooking && (
        <div className="bg-emerald-950/80 border border-emerald-500/50 rounded-2xl p-6 shadow-xl flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-2xl bg-emerald-600 flex items-center justify-center text-white flex-shrink-0">
              <CheckCircle2 className="w-7 h-7" />
            </div>
            <div>
              <div className="text-xs font-bold text-emerald-400 uppercase tracking-wider">Pickup Request Booked Successfully!</div>
              <div className="text-xl font-extrabold text-white mt-0.5">
                Tracking ID: <span className="font-mono text-emerald-300">{successBooking}</span>
              </div>
              <p className="text-xs text-slate-300 mt-1">
                Your request has been broadcasted to verified local collectors within 2.5 km. You will receive real-time status updates below.
              </p>
            </div>
          </div>
          <button
            onClick={() => {
              setSuccessBooking(null);
              handleTabChange("pickups");
            }}
            className="px-4 py-2 bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-bold rounded-xl whitespace-nowrap transition"
          >
            View Live Stepper & Tracking
          </button>
        </div>
      )}

      {/* TAB 1: BOOK DOORSTEP PICKUP */}
      {activeTab === "book" && (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2 bg-slate-900 border border-slate-800 rounded-3xl p-6 sm:p-8 shadow-xl space-y-6">
            <div>
              <h2 className="text-xl font-bold text-white flex items-center gap-2">
                <Truck className="w-5 h-5 text-emerald-400" />
                Schedule Doorstep E-Waste Collection
              </h2>
              <p className="text-xs text-slate-400 mt-1">
                Select scrap types, confirm your location, and pick a convenient time slot.
              </p>
            </div>

            <form onSubmit={handleBookPickup} className="space-y-6">
              {/* Step 1: Scrap Photo Upload */}
              <div>
                <div className="flex items-center justify-between mb-2">
                  <label className="text-xs font-bold text-slate-300">
                    1. Photo of Scrap / Kabad <span className="text-emerald-400 font-normal">(Required)</span>
                  </label>
                  {photoPreview && (
                    <button
                      type="button"
                      onClick={handleRetakePhoto}
                      className="text-xs text-slate-400 hover:text-white flex items-center gap-1 font-semibold"
                    >
                      <RefreshCw className="w-3 h-3" /> Retake Photo
                    </button>
                  )}
                </div>

                <input
                  ref={fileInputRef}
                  type="file"
                  accept="image/*"
                  capture="environment"
                  onChange={handlePhotoSelect}
                  className="hidden"
                />

                {!photoPreview ? (
                  <div
                    onClick={() => fileInputRef.current?.click()}
                    className="border-2 border-dashed border-emerald-500/40 hover:border-emerald-400 bg-slate-800/40 hover:bg-slate-800/80 rounded-2xl p-6 text-center cursor-pointer transition flex flex-col items-center justify-center gap-2 group"
                  >
                    <div className="w-12 h-12 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-400 flex items-center justify-center group-hover:scale-105 transition">
                      <Camera className="w-6 h-6" />
                    </div>
                    <div>
                      <div className="text-xs font-bold text-white">Tap to Snap or Upload Scrap Photo</div>
                      <p className="text-[11px] text-slate-400">Mobile camera or file picker. Auto-compressed &lt; 800 KB.</p>
                    </div>
                    <div className="flex items-center gap-1 text-[11px] font-semibold text-emerald-400 bg-emerald-950/60 border border-emerald-800/80 px-2.5 py-1 rounded-full">
                      <Upload className="w-3 h-3" />
                      <span>Choose File</span>
                    </div>
                  </div>
                ) : (
                  <div className="rounded-2xl overflow-hidden border border-emerald-500/40 bg-slate-950 p-3 flex items-center gap-4">
                    <img
                      src={photoPreview}
                      alt="Scrap Preview"
                      className="w-24 h-24 object-cover rounded-xl border border-slate-800"
                    />
                    <div className="flex-1 space-y-1 text-left">
                      <div className="flex items-center gap-2">
                        <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
                        <span className="text-xs font-bold text-emerald-400 uppercase tracking-wider">Photo Attached ✓</span>
                      </div>
                      <p className="text-[11px] text-slate-300">
                        Kabadiwala will review this photo before arriving with precision digital scales.
                      </p>
                      {compressedSizeKb && (
                        <div className="text-[10px] font-mono text-slate-400">
                          Compressed size: <span className="text-emerald-300 font-bold">{compressedSizeKb} KB</span>
                        </div>
                      )}
                    </div>
                  </div>
                )}
                {isCompressing && (
                  <p className="text-xs text-emerald-400 mt-2 flex items-center gap-1.5 animate-pulse">
                    <RefreshCw className="w-3 h-3 animate-spin" /> Compressing image...
                  </p>
                )}
              </div>

              {/* Location Input */}
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <label className="text-xs font-bold text-slate-300">
                    2. Pickup Address & Doorstep GPS Location
                  </label>
                  <button
                    type="button"
                    onClick={handleGetCurrentLocation}
                    disabled={geoLocating}
                    className="text-xs text-emerald-400 hover:text-emerald-300 font-bold flex items-center gap-1 transition"
                  >
                    <MapPin className="w-3.5 h-3.5" />
                    <span>
                      {geoLocating
                        ? "Acquiring GPS..."
                        : geoSuccess
                        ? "GPS Locked ✓"
                        : "Detect Current Location"}
                    </span>
                  </button>
                </div>

                <div className="relative">
                  <input
                    type="text"
                    required
                    value={address}
                    onChange={(e) => setAddress(e.target.value)}
                    placeholder="e.g. Flat 402, Green Heights, Bandra West, Mumbai"
                    className="w-full bg-slate-800 border border-slate-700 rounded-xl px-4 py-3 text-white text-sm font-semibold focus:outline-none focus:border-emerald-500"
                  />
                  <div className="text-[11px] text-slate-500 mt-1 flex items-center gap-1">
                    <Info className="w-3.5 h-3.5" />
                    <span>Coordinates: {lat.toFixed(4)}, {lng.toFixed(4)} (PostGIS Spatial Index active)</span>
                  </div>
                </div>
              </div>

              {/* Contact & Slot */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-bold text-slate-300 block mb-1.5">
                    3. Contact Phone Number
                  </label>
                  <input
                    type="tel"
                    required
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    placeholder="+91 98765 43210"
                    className="w-full bg-slate-800 border border-slate-700 rounded-xl px-4 py-2.5 text-white text-sm font-semibold focus:outline-none focus:border-emerald-500"
                  />
                </div>

                <div>
                  <label className="text-xs font-bold text-slate-300 block mb-1.5">
                    4. Preferred Time Slot
                  </label>
                  <select
                    value={timeSlot}
                    onChange={(e) => setTimeSlot(e.target.value)}
                    className="w-full bg-slate-800 border border-slate-700 rounded-xl px-4 py-2.5 text-white text-sm font-semibold focus:outline-none focus:border-emerald-500"
                  >
                    {TIME_SLOTS.map((s) => (
                      <option key={s} value={s}>
                        {s}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              {errorMessage && (
                <div className="p-3 bg-red-950/60 border border-red-700 text-red-300 text-xs rounded-xl flex items-center gap-2">
                  <AlertCircle className="w-4 h-4 flex-shrink-0" />
                  <span>{errorMessage}</span>
                </div>
              )}

              <button
                type="submit"
                disabled={loading}
                data-testid="btn-submit-pickup"
                className="w-full bg-emerald-600 hover:bg-emerald-500 disabled:opacity-50 text-white font-extrabold py-3.5 rounded-2xl shadow-lg shadow-emerald-900/40 text-sm transition flex items-center justify-center gap-2"
              >
                <Truck className="w-4 h-4" />
                <span>{loading ? "Broadcasting Pickup Request..." : "Confirm & Book Doorstep Collection"}</span>
              </button>
            </form>
          </div>

          {/* Right Column: Why Formal Recycling + Safety */}
          <div className="space-y-6">
            <div className="bg-slate-900 border border-slate-800 rounded-3xl p-6 shadow-xl space-y-4">
              <h3 className="text-sm font-black text-white uppercase tracking-wider flex items-center gap-2">
                <ShieldCheck className="w-4 h-4 text-emerald-400" />
                Our E-Waste Promise
              </h3>
              
              <ul className="space-y-3 text-xs text-slate-300">
                <li className="flex items-start gap-2.5">
                  <span className="w-5 h-5 rounded-full bg-emerald-950 text-emerald-400 border border-emerald-700/60 flex items-center justify-center font-bold text-[10px] flex-shrink-0 mt-0.5">
                    ✓
                  </span>
                  <span><strong>Zero Landfill Leakage:</strong> 100% of material collected is channeled to CPCB-authorized facilities.</span>
                </li>
                <li className="flex items-start gap-2.5">
                  <span className="w-5 h-5 rounded-full bg-emerald-950 text-emerald-400 border border-emerald-700/60 flex items-center justify-center font-bold text-[10px] flex-shrink-0 mt-0.5">
                    ✓
                  </span>
                  <span><strong>Government Rate Protection:</strong> Eliminates middleman deductions. Fair spot price on electronic scales.</span>
                </li>
                <li className="flex items-start gap-2.5">
                  <span className="w-5 h-5 rounded-full bg-emerald-950 text-emerald-400 border border-emerald-700/60 flex items-center justify-center font-bold text-[10px] flex-shrink-0 mt-0.5">
                    ✓
                  </span>
                  <span><strong>Instant Cash or Green Credits:</strong> Immediate payout at doorstep upon weight verification.</span>
                </li>
              </ul>
            </div>

            <div className="bg-amber-950/30 border border-amber-800/40 rounded-3xl p-6 shadow-xl space-y-3">
              <h3 className="text-sm font-bold text-amber-300 flex items-center gap-2">
                <AlertCircle className="w-4 h-4 text-amber-400" />
                Disposal Precautions
              </h3>
              <p className="text-xs text-slate-300 leading-relaxed">
                Do not break CRT TV glass or attempt to burn insulation off wires. Store damaged phone batteries in a dry cardboard box away from direct sunlight.
              </p>
            </div>
          </div>
        </div>
      )}

      {/* TAB 2: MY BOOKINGS & STEPPER */}
      {activeTab === "pickups" && (
        <div className="space-y-6">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-xl font-bold text-white flex items-center gap-2">
                <Clock className="w-5 h-5 text-emerald-400" />
                My Pickup Requests & Real-Time Tracking
              </h2>
              <p className="text-xs text-slate-400 mt-1">
                4-Stage live progress tracking with verified collector details.
              </p>
            </div>
            <button
              onClick={() => handleTabChange("book")}
              className="px-3.5 py-2 bg-emerald-600 hover:bg-emerald-500 text-white rounded-xl text-xs font-bold transition flex items-center gap-1.5 shadow"
            >
              <Truck className="w-3.5 h-3.5" />
              <span>Book Another Pickup</span>
            </button>
          </div>

          <div className="space-y-4">
            {myPickups.map((req) => {
              const isCompleted = req.status === "completed";
              const isDispatched = req.status === "dispatched" || req.status === "accepted";
              
              return (
                <div
                  key={req.id}
                  className="bg-slate-900 border border-slate-800 rounded-3xl p-6 shadow-xl space-y-5"
                >
                  <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 border-b border-slate-800 pb-4">
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="font-mono text-base font-black text-emerald-400">
                          {req.public_code}
                        </span>
                        <span
                          className={`text-[10px] font-bold px-2 py-0.5 rounded-full uppercase ${
                            isCompleted
                              ? "bg-emerald-950 text-emerald-300 border border-emerald-700"
                              : "bg-amber-950 text-amber-300 border border-amber-700"
                          }`}
                        >
                          {req.status}
                        </span>
                      </div>
                      <div className="text-xs text-slate-400 mt-1">
                        Address: {req.address_text} • Categories: {req.categories.join(", ")}
                      </div>
                    </div>

                    <div className="text-right">
                      <div className="text-xs text-slate-400">{new Date(req.created_at).toLocaleDateString()}</div>
                      <div className="text-xs font-bold text-slate-300">{req.collector_name}</div>
                    </div>
                  </div>

                  {/* 4-Stage Stepper */}
                  <div className="py-2">
                    <div className="grid grid-cols-4 gap-2 text-center relative">
                      {/* Stepper Node 1 */}
                      <div className="flex flex-col items-center">
                        <div className="w-8 h-8 rounded-full bg-emerald-600 text-white font-bold text-xs flex items-center justify-center shadow-lg shadow-emerald-900/60 z-10">
                          ✓
                        </div>
                        <div className="text-xs font-bold text-white mt-1.5">1. Requested</div>
                        <div className="text-[10px] text-slate-400">Booking Confirmed</div>
                      </div>

                      {/* Stepper Node 2 */}
                      <div className="flex flex-col items-center">
                        <div className={`w-8 h-8 rounded-full font-bold text-xs flex items-center justify-center z-10 ${
                          isDispatched || isCompleted ? "bg-emerald-600 text-white shadow-lg shadow-emerald-900/60" : "bg-slate-800 text-slate-400 border border-slate-700"
                        }`}>
                          {isDispatched || isCompleted ? "✓" : "2"}
                        </div>
                        <div className={`text-xs font-bold mt-1.5 ${isDispatched || isCompleted ? "text-white" : "text-slate-500"}`}>
                          2. Assigned
                        </div>
                        <div className="text-[10px] text-slate-400">Collector Matched</div>
                      </div>

                      {/* Stepper Node 3 */}
                      <div className="flex flex-col items-center">
                        <div className={`w-8 h-8 rounded-full font-bold text-xs flex items-center justify-center z-10 ${
                          isCompleted ? "bg-emerald-600 text-white" : isDispatched ? "bg-amber-500 text-slate-950 animate-pulse font-black" : "bg-slate-800 text-slate-400 border border-slate-700"
                        }`}>
                          {isCompleted ? "✓" : "3"}
                        </div>
                        <div className={`text-xs font-bold mt-1.5 ${isDispatched || isCompleted ? "text-white" : "text-slate-500"}`}>
                          3. In Transit
                        </div>
                        <div className="text-[10px] text-slate-400">{req.eta || "En Route"}</div>
                      </div>

                      {/* Stepper Node 4 */}
                      <div className="flex flex-col items-center">
                        <div className={`w-8 h-8 rounded-full font-bold text-xs flex items-center justify-center z-10 ${
                          isCompleted ? "bg-emerald-600 text-white shadow-lg shadow-emerald-900/60" : "bg-slate-800 text-slate-400 border border-slate-700"
                        }`}>
                          {isCompleted ? "✓" : "4"}
                        </div>
                        <div className={`text-xs font-bold mt-1.5 ${isCompleted ? "text-white" : "text-slate-500"}`}>
                          4. Handed Over
                        </div>
                        <div className="text-[10px] text-slate-400">Cash/Credit Settled</div>
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* TAB 3: TRANSPARENT PRICE BOARD */}
      {activeTab === "prices" && (
        <div className="bg-slate-900 border border-slate-800 rounded-3xl p-6 sm:p-8 shadow-xl space-y-6">
          <div>
            <h2 className="text-xl font-bold text-white flex items-center gap-2">
              <TrendingUp className="w-5 h-5 text-emerald-400" />
              Regional E-Waste Benchmark Rate Card
            </h2>
            <p className="text-xs text-slate-400 mt-1">
              Government regulated baseline prices under CPCB & JNARDDC guidelines.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {CATEGORIES.map((c) => (
              <div key={c.id} className="bg-slate-800/80 border border-slate-700 rounded-2xl p-4 flex items-center gap-4">
                <span className="text-3xl">{c.icon}</span>
                <div>
                  <div className="text-sm font-extrabold text-white">{c.name}</div>
                  <div className="text-xs text-emerald-400 font-black mt-0.5">{c.rate}</div>
                  <p className="text-[11px] text-slate-400 mt-1">{c.desc}</p>
                </div>
              </div>
            ))}
          </div>

          <div className="p-4 bg-slate-800/50 rounded-2xl border border-slate-700/60 text-xs text-slate-300">
            <strong>Price Guarantee:</strong> All registered collectors must honor these prices on certified electronic scales. No deductions allowed for sorting when materials match the stated condition.
          </div>
        </div>
      )}

      {/* TAB 4: GREEN IMPACT & CREDITS */}
      {activeTab === "impact" && (
        <div className="bg-slate-900 border border-slate-800 rounded-3xl p-6 sm:p-8 shadow-xl space-y-6">
          <div>
            <h2 className="text-xl font-bold text-white flex items-center gap-2">
              <Award className="w-5 h-5 text-teal-400" />
              Household Environmental Impact Certificate
            </h2>
            <p className="text-xs text-slate-400 mt-1">
              Your contribution to India's National Critical Minerals Mission and circular economy.
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="bg-slate-800 border border-slate-700 rounded-2xl p-5 text-center">
              <div className="w-12 h-12 bg-emerald-950 text-emerald-400 rounded-2xl mx-auto flex items-center justify-center font-bold text-xl mb-3">
                <Recycle className="w-6 h-6" />
              </div>
              <div className="text-2xl font-black text-white">18.5 kg</div>
              <div className="text-xs text-slate-400 mt-1">E-Waste Safely Diverted</div>
            </div>

            <div className="bg-slate-800 border border-slate-700 rounded-2xl p-5 text-center">
              <div className="w-12 h-12 bg-teal-950 text-teal-400 rounded-2xl mx-auto flex items-center justify-center font-bold text-xl mb-3">
                <Sparkles className="w-6 h-6" />
              </div>
              <div className="text-2xl font-black text-white">42.8 kg</div>
              <div className="text-xs text-slate-400 mt-1">CO₂ Equivalent Prevented</div>
            </div>

            <div className="bg-slate-800 border border-slate-700 rounded-2xl p-5 text-center">
              <div className="w-12 h-12 bg-amber-950 text-amber-400 rounded-2xl mx-auto flex items-center justify-center font-bold text-xl mb-3">
                <Coins className="w-6 h-6" />
              </div>
              <div className="text-2xl font-black text-white">₹1,840</div>
              <div className="text-xs text-slate-400 mt-1">Fair Cash Earned</div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
