"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import {
  MapPin,
  Camera,
  Upload,
  CheckCircle2,
  Clock,
  Phone,
  ArrowRight,
  ShieldCheck,
  Recycle,
  Sparkles,
  AlertCircle,
} from "lucide-react";
import { createPickupRequest, getCategoryPhotoUrl } from "@/lib/api";

const CATEGORIES = [
  { id: "CABLES", name: "Cables & Wires", desc: "Copper, charging cords, wiring", icon: "🔌" },
  { id: "BATTERIES", name: "Batteries", desc: "Inverters, UPS, phone batteries", icon: "🔋" },
  { id: "CRT", name: "TV / CRT / Screens", desc: "Old monitors, televisions", icon: "📺" },
  { id: "PCB", name: "Circuits & Motherboards", desc: "Computer boards, phones, RAM", icon: "🖥️" },
  { id: "APPLIANCES", name: "Appliances", desc: "Mixers, microwaves, fans", icon: "⚙️" },
];

const TIME_SLOTS = [
  "Immediate / Next 2 Hours",
  "Morning (9:00 AM – 12:00 PM)",
  "Afternoon (1:00 PM – 5:00 PM)",
  "Evening (5:00 PM – 8:00 PM)",
];

const DISTRICT_PRESETS = [
  { name: "Amravati (Camp / Gadge Nagar)", lat: 20.9320, lng: 77.7523 },
  { name: "Mumbai (Andheri / Bandra)", lat: 19.0760, lng: 72.8777 },
  { name: "Thane (Naupada / Majiwada)", lat: 19.2183, lng: 72.9781 },
  { name: "Pune (Shivajinagar / Kothrud)", lat: 18.5204, lng: 73.8567 },
  { name: "Nagpur (Dharampeth / Sitabuldi)", lat: 21.1458, lng: 79.0882 },
];

export default function CitizenPickupPage() {
  const router = useRouter();

  // Location State
  const [lat, setLat] = useState<number>(20.9320);
  const [lng, setLng] = useState<number>(77.7523);
  const [address, setAddress] = useState<string>("Camp Road, Amravati, Maharashtra");
  const [geoLocating, setGeoLocating] = useState<boolean>(false);
  const [geoSuccess, setGeoSuccess] = useState<boolean>(false);

  // Category & Photo State
  const [selectedCategories, setSelectedCategories] = useState<string[]>(["CABLES"]);
  const [photos, setPhotos] = useState<string[]>([]);
  const [photoPreview, setPhotoPreview] = useState<string | null>(null);

  // Contact & Slot State
  const [phone, setPhone] = useState<string>("+91 98765 43210");
  const [timeSlot, setTimeSlot] = useState<string>("Immediate / Next 2 Hours");
  const [otp, setOtp] = useState<string>("123456");

  // UI state
  const [loading, setLoading] = useState<boolean>(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const handleGetCurrentLocation = () => {
    if (!navigator.geolocation) {
      alert("Geolocation is not supported by your browser");
      return;
    }
    setGeoLocating(true);
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        setLat(Number(pos.coords.latitude.toFixed(6)));
        setLng(Number(pos.coords.longitude.toFixed(6)));
        setGeoSuccess(true);
        setGeoLocating(false);
        setAddress(`Live GPS Locked (${pos.coords.latitude.toFixed(4)}, ${pos.coords.longitude.toFixed(4)})`);
      },
      (err) => {
        console.warn("Geolocation denied/unavailable, keeping fallback coordinates:", err.message);
        setGeoLocating(false);
      },
      { timeout: 8000, enableHighAccuracy: true }
    );
  };

  const toggleCategory = (catId: string) => {
    setSelectedCategories((prev) =>
      prev.includes(catId)
        ? prev.length > 1
          ? prev.filter((c) => c !== catId)
          : prev
        : [...prev, catId]
    );
  };

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const url = URL.createObjectURL(file);
      setPhotoPreview(url);
      setPhotos([getCategoryPhotoUrl(selectedCategories[0] || "PCB")]);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrorMessage(null);

    try {
      const formattedPhone = phone.replace(/[^0-9+]/g, "");
      const res = await createPickupRequest({
        lat,
        lng,
        address,
        categories: selectedCategories,
        photos: photos.length > 0 ? photos : [getCategoryPhotoUrl(selectedCategories[0] || "CABLES")],
        phone: formattedPhone || "+919876543210",
        otp: otp || "123456",
        preferred_time_slot: timeSlot,
      });

      router.push(`/pickup/track/${res.public_code}`);
    } catch (err: any) {
      setErrorMessage(err.message || "Something went wrong while booking the pickup.");
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 flex flex-col justify-between">
      {/* Top Bar */}
      <header className="border-b border-slate-800 bg-slate-900/90 backdrop-blur sticky top-0 z-40 px-4 py-3.5">
        <div className="max-w-4xl mx-auto flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-10 h-10 rounded-xl bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-emerald-400 font-bold">
              <Recycle className="w-5 h-5 text-emerald-400" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="font-bold tracking-tight text-white text-base">Kabadiwala Connect</span>
                <span className="text-[10px] font-bold uppercase tracking-wider bg-emerald-500/20 text-emerald-300 px-2 py-0.5 rounded-full border border-emerald-500/30">
                  Citizen Portal
                </span>
              </div>
              <p className="text-xs text-slate-400">Zero-Registration Doorstep E-Waste Pickup</p>
            </div>
          </div>
          <div className="text-right hidden sm:block">
            <span className="text-xs text-emerald-400 font-medium flex items-center gap-1.5">
              <ShieldCheck className="w-4 h-4" /> 100% Cash at Doorstep
            </span>
            <p className="text-[11px] text-slate-400">Verified EPR Recyclers</p>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-3xl mx-auto w-full px-4 py-8 flex-1">
        {/* Banner */}
        <div className="bg-gradient-to-r from-emerald-950/60 via-slate-800/80 to-slate-900 border border-emerald-500/30 rounded-2xl p-6 mb-8 shadow-xl">
          <div className="flex items-start gap-3.5">
            <div className="w-10 h-10 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0 mt-0.5">
              <Sparkles className="w-5 h-5" />
            </div>
            <div>
              <h1 className="text-xl font-bold text-white mb-1">Schedule Instant Scrap Pickup</h1>
              <p className="text-sm text-slate-300 leading-relaxed">
                Connect directly with nearby verified kabadiwalas. We dispatch requests in a 2.5 km radius. 
                Zero registration, instant cash payment on weight, and environmentally safe recycling.
              </p>
            </div>
          </div>
        </div>

        {errorMessage && (
          <div className="mb-6 p-4 rounded-xl bg-rose-950/50 border border-rose-500/40 text-rose-200 text-sm flex items-center gap-3">
            <AlertCircle className="w-5 h-5 text-rose-400 shrink-0" />
            <span>{errorMessage}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-6">
          {/* STEP 1: Geotag Location */}
          <div className="bg-slate-800/60 border border-slate-700/70 rounded-2xl p-6 shadow-md">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2.5">
                <div className="w-7 h-7 rounded-lg bg-emerald-500/20 text-emerald-400 font-bold flex items-center justify-center text-xs">
                  1
                </div>
                <h2 className="text-base font-semibold text-white">Your Pickup Location</h2>
              </div>
              <button
                type="button"
                onClick={handleGetCurrentLocation}
                disabled={geoLocating}
                className="flex items-center gap-1.5 text-xs font-semibold text-emerald-400 bg-emerald-500/10 hover:bg-emerald-500/20 border border-emerald-500/30 px-3 py-1.5 rounded-lg transition"
              >
                <MapPin className="w-3.5 h-3.5" />
                {geoLocating ? "Locating..." : geoSuccess ? "GPS Locked ✓" : "Use My Live GPS"}
              </button>
            </div>

            <div className="space-y-3">
              <div>
                <label className="block text-xs font-medium text-slate-400 mb-1">
                  Street Address / Landmark
                </label>
                <input
                  type="text"
                  value={address}
                  onChange={(e) => setAddress(e.target.value)}
                  placeholder="e.g., Flat 402, Green Avenue, Camp Road, Amravati"
                  className="w-full px-3.5 py-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white placeholder-slate-500 text-sm focus:outline-none focus:border-emerald-500"
                  required
                />
              </div>

              <div className="flex flex-wrap gap-1.5 pt-1">
                <span className="text-[11px] text-slate-400 self-center mr-1">Quick Select:</span>
                {DISTRICT_PRESETS.map((p) => (
                  <button
                    key={p.name}
                    type="button"
                    onClick={() => {
                      setLat(p.lat);
                      setLng(p.lng);
                      setAddress(p.name);
                      setGeoSuccess(true);
                    }}
                    className={`text-xs px-2.5 py-1 rounded-md border transition ${
                      lat === p.lat && lng === p.lng
                        ? "bg-emerald-500/20 border-emerald-500/60 text-emerald-300 font-medium"
                        : "bg-slate-900/60 border-slate-700 text-slate-400 hover:text-slate-200"
                    }`}
                  >
                    {p.name.split(" ")[0]}
                  </button>
                ))}
              </div>

              <div className="text-[11px] text-slate-400 font-mono bg-slate-950/60 p-2.5 rounded-lg border border-slate-800 flex items-center justify-between">
                <span>Lat: {lat} | Lng: {lng}</span>
                <span className="text-emerald-400">PostGIS Coordinates Ready</span>
              </div>
            </div>
          </div>

          {/* STEP 2: Categories & Photos */}
          <div className="bg-slate-800/60 border border-slate-700/70 rounded-2xl p-6 shadow-md">
            <div className="flex items-center gap-2.5 mb-4">
              <div className="w-7 h-7 rounded-lg bg-emerald-500/20 text-emerald-400 font-bold flex items-center justify-center text-xs">
                2
              </div>
              <h2 className="text-base font-semibold text-white">Select E-Waste Categories</h2>
            </div>

            <div className="grid grid-cols-2 sm:grid-cols-3 gap-2.5 mb-5">
              {CATEGORIES.map((cat) => {
                const isSelected = selectedCategories.includes(cat.id);
                return (
                  <button
                    key={cat.id}
                    type="button"
                    onClick={() => toggleCategory(cat.id)}
                    className={`p-3 rounded-xl border text-left flex flex-col justify-between transition-all ${
                      isSelected
                        ? "bg-emerald-950/40 border-emerald-500/70 text-white shadow-sm ring-1 ring-emerald-500/30"
                        : "bg-slate-900/60 border-slate-700 text-slate-400 hover:border-slate-600"
                    }`}
                  >
                    <div className="flex items-center justify-between mb-2">
                      <span className="text-2xl">{cat.icon}</span>
                      {isSelected && <CheckCircle2 className="w-4 h-4 text-emerald-400" />}
                    </div>
                    <div>
                      <div className="text-xs font-semibold text-white">{cat.name}</div>
                      <div className="text-[10px] text-slate-400 line-clamp-1">{cat.desc}</div>
                    </div>
                  </button>
                );
              })}
            </div>

            {/* Photo Upload Card */}
            <div>
              <label className="block text-xs font-medium text-slate-400 mb-2">
                Photo of Scrap (Optional - Helps Collector Estimate Vehicle)
              </label>
              <div className="border-2 border-dashed border-slate-700 hover:border-emerald-500/50 rounded-xl p-4 text-center bg-slate-900/40 relative">
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleFileUpload}
                  className="absolute inset-0 opacity-0 cursor-pointer"
                />
                {photoPreview ? (
                  <div className="flex items-center justify-center gap-3">
                    <img src={photoPreview} alt="Preview" className="w-16 h-16 object-cover rounded-lg border border-slate-700" />
                    <div className="text-left">
                      <span className="text-xs text-emerald-400 font-medium block">Photo attached ✓</span>
                      <span className="text-[11px] text-slate-400">Tap to replace</span>
                    </div>
                  </div>
                ) : (
                  <div className="flex flex-col items-center gap-1.5 py-1">
                    <div className="w-9 h-9 rounded-full bg-slate-800 text-slate-300 flex items-center justify-center">
                      <Camera className="w-4 h-4" />
                    </div>
                    <span className="text-xs text-slate-300 font-medium">Tap to snap or upload scrap photo</span>
                    <span className="text-[10px] text-slate-500">Auto-compressed for fast dispatch</span>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* STEP 3: Phone & Time Window */}
          <div className="bg-slate-800/60 border border-slate-700/70 rounded-2xl p-6 shadow-md">
            <div className="flex items-center gap-2.5 mb-4">
              <div className="w-7 h-7 rounded-lg bg-emerald-500/20 text-emerald-400 font-bold flex items-center justify-center text-xs">
                3
              </div>
              <h2 className="text-base font-semibold text-white">Preferred Slot & Contact</h2>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-medium text-slate-400 mb-1">
                  Mobile Number (For Collector Arrival Call)
                </label>
                <div className="relative">
                  <Phone className="w-4 h-4 text-slate-500 absolute left-3 top-3" />
                  <input
                    type="tel"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    placeholder="+91 98765 43210"
                    className="w-full pl-9 pr-3.5 py-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white placeholder-slate-500 text-sm focus:outline-none focus:border-emerald-500"
                    required
                  />
                </div>
                <span className="text-[10px] text-slate-500 mt-1 block">One-time OTP verification (Mock: 123456)</span>
              </div>

              <div>
                <label className="block text-xs font-medium text-slate-400 mb-1">
                  Preferred Pickup Window
                </label>
                <div className="relative">
                  <Clock className="w-4 h-4 text-slate-500 absolute left-3 top-3" />
                  <select
                    value={timeSlot}
                    onChange={(e) => setTimeSlot(e.target.value)}
                    className="w-full pl-9 pr-3.5 py-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none focus:border-emerald-500 appearance-none"
                  >
                    {TIME_SLOTS.map((slot) => (
                      <option key={slot} value={slot} className="bg-slate-900 text-white">
                        {slot}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
            </div>
          </div>

          {/* Submit Action */}
          <button
            type="submit"
            disabled={loading}
            className="w-full py-4 rounded-xl font-bold text-slate-950 bg-gradient-to-r from-emerald-400 to-teal-400 hover:from-emerald-300 hover:to-teal-300 shadow-lg shadow-emerald-500/20 flex items-center justify-center gap-2 transition disabled:opacity-50 text-base"
          >
            {loading ? (
              <span>Dispatching to Nearby Collectors...</span>
            ) : (
              <>
                <span>Request Doorstep Pickup Now</span>
                <ArrowRight className="w-5 h-5" />
              </>
            )}
          </button>
        </form>
      </main>

      {/* Footer */}
      <footer className="border-t border-slate-800 py-4 px-4 text-center text-xs text-slate-500">
        Kabadiwala Connect — JNARDDC / Smart India Hackathon PS 26229
      </footer>
    </div>
  );
}
