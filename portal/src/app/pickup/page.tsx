"use client";

import React, { useState, useRef } from "react";
import { useRouter } from "next/navigation";
import {
  MapPin,
  Camera,
  Upload,
  Clock,
  Phone,
  ArrowRight,
  ShieldCheck,
  Recycle,
  Sparkles,
  AlertCircle,
  RefreshCw,
} from "lucide-react";
import { createPickupRequest, getCategoryPhotoUrl } from "@/lib/api";
import { compressImageToWebP, uploadScrapPhotoToSupabase } from "@/lib/imageUtils";

const TIME_SLOTS = [
  "Immediate (Next 2 Hours)",
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
  const fileInputRef = useRef<HTMLInputElement>(null);

  // 1. Scrap Photo State
  const [photoFile, setPhotoFile] = useState<File | null>(null);
  const [photoPreview, setPhotoPreview] = useState<string | null>(null);
  const [compressedSizeKb, setCompressedSizeKb] = useState<number | null>(null);
  const [isCompressing, setIsCompressing] = useState<boolean>(false);

  // 2. Location State
  const [lat, setLat] = useState<number>(20.9320);
  const [lng, setLng] = useState<number>(77.7523);
  const [address, setAddress] = useState<string>("Camp Road, Amravati, Maharashtra");
  const [geoLocating, setGeoLocating] = useState<boolean>(false);
  const [geoSuccess, setGeoSuccess] = useState<boolean>(false);

  // 3. Contact Phone & 4. Time Slot State
  const [phone, setPhone] = useState<string>("+91 98765 43210");
  const [timeSlot, setTimeSlot] = useState<string>("Immediate (Next 2 Hours)");
  const [otp] = useState<string>("123456");

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

  const handlePhotoSelect = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setIsCompressing(true);
    setErrorMessage(null);

    try {
      // Client-side HTML5 Canvas compression to < 800 KB
      const compressedBlob = await compressImageToWebP(file, 800);
      const compressedFile = new File([compressedBlob], `scrap_${Date.now()}.webp`, {
        type: compressedBlob.type || "image/webp",
      });

      setPhotoFile(compressedFile);
      setCompressedSizeKb(Math.round(compressedFile.size / 1024));

      const objectUrl = URL.createObjectURL(compressedFile);
      setPhotoPreview(objectUrl);
    } catch (err: any) {
      console.error("Compression error:", err);
      // Fallback to raw file
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

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!photoFile && !photoPreview) {
      setErrorMessage("Please snap or upload a photo of your scrap before submitting.");
      return;
    }

    setLoading(true);
    setErrorMessage(null);

    try {
      let finalPhotoUrl = "";

      // Step A: Upload compressed image to Supabase Storage bucket 'scrap-photos'
      if (photoFile) {
        try {
          finalPhotoUrl = await uploadScrapPhotoToSupabase(
            photoFile,
            `citizen_${Date.now()}_${Math.random().toString(36).substring(2, 7)}.webp`
          );
        } catch (uploadErr) {
          console.warn("Direct Supabase bucket upload failed, using CDN reference:", uploadErr);
          finalPhotoUrl = getCategoryPhotoUrl("mixed_ewaste");
        }
      } else {
        finalPhotoUrl = getCategoryPhotoUrl("mixed_ewaste");
      }

      const formattedPhone = phone.replace(/[^0-9+]/g, "");

      // Step B: Submit photo-first pickup request (zero categories or weights required from citizen)
      const res = await createPickupRequest({
        lat,
        lng,
        address,
        categories: [], // Classification happens on-site via Kabadiwala mobile app
        photos: [finalPhotoUrl],
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
              <p className="text-xs text-slate-400">Photo-First Doorstep Scrap Collection</p>
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
              <h1 className="text-xl font-bold text-white mb-1">Instant Photo-First Scrap Pickup</h1>
              <p className="text-sm text-slate-300 leading-relaxed">
                Just snap a photo of your kabad/e-waste. No complex category selections or weighing needed. 
                Our verified kabadiwala arrives with digital scales, edge AI classification, and cash in hand.
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
          {/* STEP 1: Mandatory Scrap Photo Upload / Camera */}
          <div className="bg-slate-800/60 border border-slate-700/70 rounded-2xl p-6 shadow-md">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2.5">
                <div className="w-7 h-7 rounded-lg bg-emerald-500/20 text-emerald-400 font-bold flex items-center justify-center text-xs">
                  1
                </div>
                <div>
                  <h2 className="text-base font-semibold text-white">Photo of Scrap / Kabad</h2>
                  <span className="text-[11px] text-emerald-400 font-medium">Mandatory — Kabadiwala verifies before dispatch</span>
                </div>
              </div>
              {photoPreview && (
                <button
                  type="button"
                  onClick={handleRetakePhoto}
                  className="flex items-center gap-1.5 text-xs font-semibold text-slate-300 hover:text-white bg-slate-700/60 hover:bg-slate-700 px-3 py-1.5 rounded-lg border border-slate-600 transition"
                >
                  <RefreshCw className="w-3.5 h-3.5" />
                  Retake / Change Photo
                </button>
              )}
            </div>

            {/* Hidden file input supporting mobile camera capture & desktop file picker */}
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
                className="border-2 border-dashed border-emerald-500/40 hover:border-emerald-400 bg-slate-900/60 hover:bg-slate-900/90 rounded-2xl p-8 text-center cursor-pointer transition flex flex-col items-center justify-center gap-3 group"
              >
                <div className="w-14 h-14 rounded-2xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-400 flex items-center justify-center group-hover:scale-105 transition">
                  <Camera className="w-7 h-7" />
                </div>
                <div>
                  <div className="text-sm font-bold text-white mb-1">
                    Tap to Snap or Upload Scrap Photo
                  </div>
                  <p className="text-xs text-slate-400 max-w-sm">
                    Supports live mobile camera or gallery upload. Auto-compressed to &lt; 800 KB for fast mobile dispatch.
                  </p>
                </div>
                <div className="flex items-center gap-2 text-xs font-semibold text-emerald-400 bg-emerald-950/60 border border-emerald-800/80 px-3 py-1.5 rounded-full mt-1">
                  <Upload className="w-3.5 h-3.5" />
                  <span>Choose from Gallery or Camera</span>
                </div>
              </div>
            ) : (
              <div className="relative rounded-2xl overflow-hidden border border-emerald-500/40 bg-slate-950 p-3">
                <div className="flex flex-col sm:flex-row items-center gap-4">
                  <img
                    src={photoPreview}
                    alt="Scrap Preview"
                    className="w-full sm:w-48 h-44 object-cover rounded-xl border border-slate-800"
                  />
                  <div className="flex-1 space-y-2 text-left w-full">
                    <div className="flex items-center gap-2">
                      <span className="w-2.5 h-2.5 rounded-full bg-emerald-400 animate-pulse"></span>
                      <span className="text-xs font-bold text-emerald-400 uppercase tracking-wider">
                        Scrap Photo Ready
                      </span>
                    </div>
                    <p className="text-xs text-slate-300">
                      Photo will be securely stored in Supabase Storage and shared with nearby verified kabadiwalas for instant dispatch.
                    </p>
                    {compressedSizeKb && (
                      <div className="text-[11px] font-mono text-slate-400 bg-slate-900 px-3 py-1.5 rounded-lg border border-slate-800 inline-block">
                        Compressed size: <span className="text-emerald-300 font-bold">{compressedSizeKb} KB</span> (&lt; 800 KB target)
                      </div>
                    )}
                    <div>
                      <button
                        type="button"
                        onClick={handleRetakePhoto}
                        className="text-xs text-slate-400 hover:text-emerald-300 underline font-medium"
                      >
                        Click here to replace with another photo
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            )}
            {isCompressing && (
              <p className="text-xs text-emerald-400 mt-2 flex items-center gap-1.5 animate-pulse">
                <RefreshCw className="w-3 h-3 animate-spin" /> Compressing image for fast upload...
              </p>
            )}
          </div>

          {/* STEP 2: Pickup Address & Doorstep GPS Location */}
          <div className="bg-slate-800/60 border border-slate-700/70 rounded-2xl p-6 shadow-md">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2.5">
                <div className="w-7 h-7 rounded-lg bg-emerald-500/20 text-emerald-400 font-bold flex items-center justify-center text-xs">
                  2
                </div>
                <h2 className="text-base font-semibold text-white">Pickup Address & GPS Location</h2>
              </div>
              <button
                type="button"
                onClick={handleGetCurrentLocation}
                disabled={geoLocating}
                className="flex items-center gap-1.5 text-xs font-semibold text-emerald-400 bg-emerald-500/10 hover:bg-emerald-500/20 border border-emerald-500/30 px-3 py-1.5 rounded-lg transition"
              >
                <MapPin className="w-3.5 h-3.5" />
                {geoLocating ? "Locating..." : geoSuccess ? "GPS Locked ✓" : "Detect Current Location"}
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

          {/* STEP 3 & 4: Contact Phone & Preferred Time Window */}
          <div className="bg-slate-800/60 border border-slate-700/70 rounded-2xl p-6 shadow-md">
            <div className="flex items-center gap-2.5 mb-4">
              <div className="w-7 h-7 rounded-lg bg-emerald-500/20 text-emerald-400 font-bold flex items-center justify-center text-xs">
                3
              </div>
              <h2 className="text-base font-semibold text-white">Contact & Preferred Slot</h2>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-medium text-slate-400 mb-1">
                  3. Mobile Number (For Collector Arrival Call)
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
                <span className="text-[10px] text-slate-500 mt-1 block">One-time OTP verification (Demo: 123456)</span>
              </div>

              <div>
                <label className="block text-xs font-medium text-slate-400 mb-1">
                  4. Preferred Pickup Window
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
            disabled={loading || isCompressing}
            className="w-full py-4 rounded-xl font-bold text-slate-950 bg-gradient-to-r from-emerald-400 to-teal-400 hover:from-emerald-300 hover:to-teal-300 shadow-lg shadow-emerald-500/20 flex items-center justify-center gap-2 transition disabled:opacity-50 text-base"
          >
            {loading ? (
              <span>Broadcasting Photo to Nearby Kabadiwalas...</span>
            ) : (
              <>
                <span>Confirm & Book Doorstep Collection</span>
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
