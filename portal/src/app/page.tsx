"use client";

import React, { useState } from "react";
import { useAuth } from "../context/AuthContext";
import { useLanguage } from "../context/LanguageContext";
import { Navbar } from "../components/Navbar";
import { Sidebar } from "../components/Sidebar";
import { PublicDashboardView } from "../components/views/PublicDashboardView";
import { RecyclerDashboardView } from "../components/views/RecyclerDashboardView";
import { MatchedLotsInboxView } from "../components/views/MatchedLotsInboxView";
import { HandoverConfirmationView } from "../components/views/HandoverConfirmationView";
import { DownstreamTrackingView } from "../components/views/DownstreamTrackingView";
import { RecyclerProfileView } from "../components/views/RecyclerProfileView";
import { AdminVerificationQueueView } from "../components/views/AdminVerificationQueueView";
import { AdminExpiryAlertsView } from "../components/views/AdminExpiryAlertsView";
import { AdminPriceBoardView } from "../components/views/AdminPriceBoardView";
import { AdminAnomalyReviewView } from "../components/views/AdminAnomalyReviewView";
import { AdminAnalyticsView } from "../components/views/AdminAnalyticsView";
import {
  LayoutDashboard,
  Inbox,
  QrCode,
  Truck,
  FileBadge,
  UserCheck,
  AlertTriangle,
  TrendingUp,
  ShieldAlert,
  BarChart3,
  Lock,
  Building2,
  ShieldCheck,
  User,
  Smartphone,
  Sparkles,
  ArrowRight,
  CheckCircle2,
  KeyRound,
  Clock,
  Award,
  ChevronRight,
  ArrowLeft,
} from "lucide-react";

export default function PortalPage() {
  const { user, login, register } = useAuth();
  const { t } = useLanguage();
  const [activeTab, setActiveTab] = useState<string>("dashboard");

  // Login Role: 'public' | 'recycler' | 'admin'
  const [loginRole, setLoginRole] = useState<"public" | "recycler" | "admin">("recycler");
  const [isRegisterMode, setIsRegisterMode] = useState<boolean>(false);

  // Form Fields
  const [email, setEmail] = useState<string>("recycler@ecorecycle.in");
  const [password, setPassword] = useState<string>("recycler123");
  const [name, setName] = useState<string>("Sunita Sharma");
  const [phone, setPhone] = useState<string>("+91 98765 43210");
  const [address, setAddress] = useState<string>("Bandra West, Mumbai");
  const [loading, setLoading] = useState<boolean>(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  const handleRoleSelect = (role: "public" | "recycler" | "admin") => {
    setLoginRole(role);
    setIsRegisterMode(false);
    setErrorMsg(null);
    if (role === "admin") {
      setEmail("admin@jnarddc.gov.in");
      setPassword("admin123");
    } else if (role === "public") {
      setEmail("citizen@mumbai.gov.in");
      setPassword("citizen123");
    } else {
      setEmail("recycler@ecorecycle.in");
      setPassword("recycler123");
    }
  };

  const handleLoginSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrorMsg(null);
    try {
      await login(email, loginRole, password);
      if (loginRole === "admin") {
        setActiveTab("verification");
      } else if (loginRole === "public") {
        setActiveTab("citizen_dashboard");
      } else {
        setActiveTab("dashboard");
      }
    } catch (err: any) {
      setErrorMsg(err.message || "Failed to sign in. Please verify your credentials.");
    } finally {
      setLoading(false);
    }
  };

  const handleRegisterSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrorMsg(null);
    try {
      await register(name, email, password, phone, address);
      setActiveTab("citizen_dashboard");
    } catch (err: any) {
      setErrorMsg(err.message || "Failed to create citizen account.");
    } finally {
      setLoading(false);
    }
  };

  // --------------------------------------------------------------------------
  // FIRST SCREEN: Unauthenticated Role Selection & Login Form
  // --------------------------------------------------------------------------
  if (!user) {
    return (
      <div className="min-h-screen bg-slate-950 flex flex-col justify-between">
        <Navbar />

        <main className="flex-1 flex items-center justify-center p-4 sm:p-6 lg:p-8">
          <div className="bg-slate-900 border border-slate-800 rounded-3xl p-6 sm:p-8 max-w-2xl w-full shadow-2xl space-y-7">
            {/* Main Header */}
            <div className="text-center space-y-2">
              <div className="w-14 h-14 bg-emerald-600 rounded-2xl mx-auto flex items-center justify-center font-black text-2xl text-white shadow-lg shadow-emerald-900/50">
                KC
              </div>
              <h1 className="text-2xl sm:text-3xl font-black text-white tracking-tight">
                Kabadiwala Connect Portal
              </h1>
              <p className="text-xs text-slate-400 max-w-md mx-auto">
                Step 1: Choose your access role to enter the verified digital circular economy ecosystem.
              </p>
            </div>

            {/* STEP 1: 3 Role Selector Cards */}
            <div className="space-y-2">
              <label className="text-xs font-bold text-slate-300 block uppercase tracking-wider">
                Select Your Role
              </label>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                {/* Role 1: Citizen */}
                <button
                  type="button"
                  data-testid="select-role-public"
                  onClick={() => handleRoleSelect("public")}
                  className={`p-4 rounded-2xl border text-left transition-all relative flex flex-col justify-between ${
                    loginRole === "public"
                      ? "bg-teal-950/60 border-teal-500 shadow-lg shadow-teal-950/50 ring-2 ring-teal-500/30"
                      : "bg-slate-800/60 border-slate-700/80 hover:border-slate-600"
                  }`}
                >
                  <div>
                    <div className="w-10 h-10 rounded-xl bg-teal-500/20 text-teal-400 flex items-center justify-center font-bold mb-3">
                      <User className="w-5 h-5" />
                    </div>
                    <div className="text-sm font-black text-white">Public / Citizen</div>
                    <p className="text-[11px] text-slate-400 mt-1 leading-snug">
                      Households booking doorstep scrap pickup & earning cash.
                    </p>
                  </div>
                  <div className="mt-3 pt-2 border-t border-slate-700/50 flex items-center justify-between text-[11px] font-bold text-teal-400">
                    <span>{loginRole === "public" ? "Selected" : "Select Role"}</span>
                    <ChevronRight className="w-3.5 h-3.5" />
                  </div>
                </button>

                {/* Role 2: Recycler */}
                <button
                  type="button"
                  data-testid="select-role-recycler"
                  onClick={() => handleRoleSelect("recycler")}
                  className={`p-4 rounded-2xl border text-left transition-all relative flex flex-col justify-between ${
                    loginRole === "recycler"
                      ? "bg-emerald-950/60 border-emerald-500 shadow-lg shadow-emerald-950/50 ring-2 ring-emerald-500/30"
                      : "bg-slate-800/60 border-slate-700/80 hover:border-slate-600"
                  }`}
                >
                  <div>
                    <div className="w-10 h-10 rounded-xl bg-emerald-500/20 text-emerald-400 flex items-center justify-center font-bold mb-3">
                      <Building2 className="w-5 h-5" />
                    </div>
                    <div className="text-sm font-black text-white">Authorized Recycler</div>
                    <p className="text-[11px] text-slate-400 mt-1 leading-snug">
                      CPCB/SPCB licensed aggregators managing lots & EPR.
                    </p>
                  </div>
                  <div className="mt-3 pt-2 border-t border-slate-700/50 flex items-center justify-between text-[11px] font-bold text-emerald-400">
                    <span>{loginRole === "recycler" ? "Selected" : "Select Role"}</span>
                    <ChevronRight className="w-3.5 h-3.5" />
                  </div>
                </button>

                {/* Role 3: Admin */}
                <button
                  type="button"
                  data-testid="select-role-admin"
                  onClick={() => handleRoleSelect("admin")}
                  className={`p-4 rounded-2xl border text-left transition-all relative flex flex-col justify-between ${
                    loginRole === "admin"
                      ? "bg-amber-950/60 border-amber-500 shadow-lg shadow-amber-950/50 ring-2 ring-amber-500/30"
                      : "bg-slate-800/60 border-slate-700/80 hover:border-slate-600"
                  }`}
                >
                  <div>
                    <div className="w-10 h-10 rounded-xl bg-amber-500/20 text-amber-400 flex items-center justify-center font-bold mb-3">
                      <ShieldCheck className="w-5 h-5" />
                    </div>
                    <div className="text-sm font-black text-white">Govt Admin</div>
                    <p className="text-[11px] text-slate-400 mt-1 leading-snug">
                      Ministry of Mines / JNARDDC compliance & anomaly audit.
                    </p>
                  </div>
                  <div className="mt-3 pt-2 border-t border-slate-700/50 flex items-center justify-between text-[11px] font-bold text-amber-400">
                    <span>{loginRole === "admin" ? "Selected" : "Select Role"}</span>
                    <ChevronRight className="w-3.5 h-3.5" />
                  </div>
                </button>
              </div>
            </div>

            {/* STEP 2: Respective Credentials & Login Form */}
            <div className="bg-slate-800/50 border border-slate-700/70 rounded-2xl p-5 sm:p-6 space-y-5">
              {/* Role Header Banner */}
              <div className="flex items-center justify-between border-b border-slate-700/70 pb-3">
                <div className="flex items-center gap-2">
                  <KeyRound className="w-4 h-4 text-emerald-400" />
                  <span className="text-xs font-black text-white uppercase tracking-wider">
                    Step 2: Enter {loginRole === "public" ? "Citizen" : loginRole === "admin" ? "Admin" : "Recycler"} Credentials
                  </span>
                </div>

                {/* Quick 1-Click Demo Shortcut */}
                <div className="flex items-center gap-2">
                  {loginRole === "recycler" && (
                    <button
                      type="button"
                      data-testid="btn-demo-recycler"
                      onClick={async () => {
                        setEmail("recycler@ecorecycle.in");
                        setPassword("recycler123");
                        await login("recycler@ecorecycle.in", "recycler");
                        setActiveTab("dashboard");
                      }}
                      className="px-2.5 py-1 bg-emerald-600 hover:bg-emerald-500 text-white text-[11px] font-bold rounded-lg transition shadow"
                    >
                      1-Click Recycler Demo
                    </button>
                  )}
                  {loginRole === "admin" && (
                    <button
                      type="button"
                      data-testid="btn-demo-admin"
                      onClick={async () => {
                        setEmail("admin@jnarddc.gov.in");
                        setPassword("admin123");
                        await login("admin@jnarddc.gov.in", "admin");
                        setActiveTab("verification");
                      }}
                      className="px-2.5 py-1 bg-amber-600 hover:bg-amber-500 text-white text-[11px] font-bold rounded-lg transition shadow"
                    >
                      1-Click Admin Demo
                    </button>
                  )}
                  {loginRole === "public" && (
                    <button
                      type="button"
                      data-testid="btn-demo-citizen"
                      onClick={async () => {
                        setEmail("citizen@mumbai.gov.in");
                        setPassword("citizen123");
                        await login("citizen@mumbai.gov.in", "public");
                        setActiveTab("citizen_dashboard");
                      }}
                      className="px-2.5 py-1 bg-teal-600 hover:bg-teal-500 text-white text-[11px] font-bold rounded-lg transition shadow"
                    >
                      1-Click Citizen Demo
                    </button>
                  )}
                </div>
              </div>

              {/* Hardcoded Credentials Callout for Recycler & Admin */}
              {loginRole === "recycler" && (
                <div className="p-3 bg-emerald-950/40 border border-emerald-500/30 rounded-xl text-xs text-slate-300">
                  <div className="font-bold text-emerald-400">Hardcoded Demo Credentials:</div>
                  <div className="font-mono mt-0.5 text-white">
                    Email: <span className="text-emerald-300 font-bold">recycler@ecorecycle.in</span> | Password: <span className="text-emerald-300 font-bold">recycler123</span>
                  </div>
                </div>
              )}

              {loginRole === "admin" && (
                <div className="p-3 bg-amber-950/40 border border-amber-500/30 rounded-xl text-xs text-slate-300">
                  <div className="font-bold text-amber-400">Hardcoded Demo Credentials:</div>
                  <div className="font-mono mt-0.5 text-white">
                    Email: <span className="text-amber-300 font-bold">admin@jnarddc.gov.in</span> | Password: <span className="text-amber-300 font-bold">admin123</span>
                  </div>
                </div>
              )}

              {/* Public Tab: Toggle between Sign In & Register */}
              {loginRole === "public" && (
                <div className="flex border-b border-slate-700">
                  <button
                    type="button"
                    onClick={() => setIsRegisterMode(false)}
                    className={`flex-1 py-2 text-xs font-bold border-b-2 transition ${
                      !isRegisterMode
                        ? "border-teal-500 text-teal-400"
                        : "border-transparent text-slate-400 hover:text-white"
                    }`}
                  >
                    Citizen Sign In
                  </button>
                  <button
                    type="button"
                    onClick={() => setIsRegisterMode(true)}
                    className={`flex-1 py-2 text-xs font-bold border-b-2 transition ${
                      isRegisterMode
                        ? "border-teal-500 text-teal-400"
                        : "border-transparent text-slate-400 hover:text-white"
                    }`}
                  >
                    Create New Account (Register)
                  </button>
                </div>
              )}

              {/* Form A: Register for Citizen */}
              {loginRole === "public" && isRegisterMode ? (
                <form onSubmit={handleRegisterSubmit} className="space-y-3.5">
                  <div>
                    <label className="text-xs font-bold text-slate-300 block mb-1">
                      Full Name
                    </label>
                    <input
                      type="text"
                      required
                      value={name}
                      onChange={(e) => setName(e.target.value)}
                      placeholder="e.g. Sunita Sharma"
                      className="w-full bg-slate-800 border border-slate-700 rounded-xl px-4 py-2 text-white text-sm font-semibold focus:outline-none focus:border-teal-500"
                    />
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="text-xs font-bold text-slate-300 block mb-1">
                        Email Address
                      </label>
                      <input
                        type="email"
                        required
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        placeholder="citizen@mumbai.gov.in"
                        className="w-full bg-slate-800 border border-slate-700 rounded-xl px-4 py-2 text-white text-sm font-semibold focus:outline-none focus:border-teal-500"
                      />
                    </div>
                    <div>
                      <label className="text-xs font-bold text-slate-300 block mb-1">
                        Phone Number
                      </label>
                      <input
                        type="tel"
                        required
                        value={phone}
                        onChange={(e) => setPhone(e.target.value)}
                        placeholder="+91 98765 43210"
                        className="w-full bg-slate-800 border border-slate-700 rounded-xl px-4 py-2 text-white text-sm font-semibold focus:outline-none focus:border-teal-500"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="text-xs font-bold text-slate-300 block mb-1">
                      Address / District
                    </label>
                    <input
                      type="text"
                      required
                      value={address}
                      onChange={(e) => setAddress(e.target.value)}
                      placeholder="e.g. Bandra West, Mumbai, Maharashtra"
                      className="w-full bg-slate-800 border border-slate-700 rounded-xl px-4 py-2 text-white text-sm font-semibold focus:outline-none focus:border-teal-500"
                    />
                  </div>

                  <div>
                    <label className="text-xs font-bold text-slate-300 block mb-1">
                      Create Password
                    </label>
                    <input
                      type="password"
                      required
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      placeholder="Minimum 6 characters"
                      className="w-full bg-slate-800 border border-slate-700 rounded-xl px-4 py-2 text-white text-sm font-semibold focus:outline-none focus:border-teal-500"
                    />
                  </div>

                  {errorMsg && (
                    <div className="p-2.5 bg-red-950/60 border border-red-700 text-red-300 text-xs rounded-xl">
                      {errorMsg}
                    </div>
                  )}

                  <button
                    type="submit"
                    disabled={loading}
                    className="w-full bg-teal-600 hover:bg-teal-500 text-white font-extrabold py-3 rounded-xl shadow-lg shadow-teal-900/40 text-sm transition"
                  >
                    {loading ? "Registering Account..." : "Create Account & Enter Portal"}
                  </button>
                </form>
              ) : (
                /* Form B: Standard Sign In */
                <form onSubmit={handleLoginSubmit} className="space-y-4">
                  <div>
                    <label className="text-xs font-bold text-slate-300 block mb-1">
                      {t.emailPlaceholder}
                    </label>
                    <input
                      type="email"
                      required
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="e.g. recycler@ecorecycle.in or admin@jnarddc.gov.in"
                      data-testid="input-email"
                      className="w-full bg-slate-800 border border-slate-700 rounded-xl px-4 py-2.5 text-white text-sm font-semibold focus:outline-none focus:border-emerald-500"
                    />
                  </div>

                  <div>
                    <label className="text-xs font-bold text-slate-300 block mb-1">
                      {t.passwordPlaceholder}
                    </label>
                    <input
                      type="password"
                      required
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      data-testid="input-password"
                      className="w-full bg-slate-800 border border-slate-700 rounded-xl px-4 py-2.5 text-white text-sm font-semibold focus:outline-none focus:border-emerald-500"
                    />
                  </div>

                  {errorMsg && (
                    <div className="p-2.5 bg-red-950/60 border border-red-700 text-red-300 text-xs rounded-xl">
                      {errorMsg}
                    </div>
                  )}

                  <button
                    type="submit"
                    data-testid="btn-login-submit"
                    disabled={loading}
                    className={`w-full font-extrabold py-3 rounded-xl shadow-lg text-sm transition text-white ${
                      loginRole === "admin"
                        ? "bg-amber-600 hover:bg-amber-500 shadow-amber-900/40"
                        : loginRole === "public"
                        ? "bg-teal-600 hover:bg-teal-500 shadow-teal-900/40"
                        : "bg-emerald-600 hover:bg-emerald-500 shadow-emerald-900/40"
                    }`}
                  >
                    {loading ? "Authenticating..." : `${t.btnSignIn} as ${loginRole === "admin" ? "Admin" : loginRole === "public" ? "Citizen" : "Recycler"}`}
                  </button>
                </form>
              )}
            </div>

            {/* Note on Collector Mobile App Separation */}
            <div className="p-3 bg-slate-950 rounded-2xl border border-slate-800/80 text-[11px] text-slate-400 flex items-start gap-2.5">
              <Smartphone className="w-4 h-4 text-emerald-400 flex-shrink-0 mt-0.5" />
              <div>
                <strong className="text-slate-300">Are you an informal scrap collector (*kabadiwala*)?</strong>
                <p className="mt-0.5 leading-relaxed">
                  Collectors do not use this web portal. Collectors use our specialized <strong>Flutter Android Mobile App</strong> featuring Devanagari voice guidance, offline Drift SQLite, and on-device AI scrap valuation.
                </p>
              </div>
            </div>
          </div>
        </main>
      </div>
    );
  }

  // --------------------------------------------------------------------------
  // SECOND SCREEN: Authenticated Portal Shell
  // --------------------------------------------------------------------------
  const adminOnlyTabs = ["verification", "expiry", "price_board", "anomalies", "analytics"];
  const isAccessForbidden = user.role === "recycler" && adminOnlyTabs.includes(activeTab);

  return (
    <div className="min-h-screen bg-slate-950 flex flex-col">
      <Navbar />

      <div className="flex-1 flex overflow-hidden">
        {/* Responsive Desktop Sidebar */}
        <Sidebar activeTab={activeTab} setActiveTab={setActiveTab} />

        {/* Main Content Area */}
        <main className="flex-1 overflow-y-auto p-4 sm:p-6 lg:p-8 max-w-7xl mx-auto w-full pb-20 md:pb-8">
          {/* Public Citizen View — receives the outer activeTab so sidebar tabs drive the sub-view */}
          {user.role === "public" ? (
            <PublicDashboardView activeTab={activeTab} setActiveTab={setActiveTab} />
          ) : isAccessForbidden ? (
            <div className="bg-slate-900 border border-amber-800/50 rounded-2xl p-8 text-center space-y-4 max-w-lg mx-auto mt-12 shadow-xl">
              <div className="w-12 h-12 rounded-full bg-amber-950 text-amber-400 border border-amber-700 flex items-center justify-center mx-auto">
                <ShieldCheck className="w-6 h-6" />
              </div>
              <h2 className="text-xl font-bold text-white">Access Restricted</h2>
              <p className="text-xs text-slate-400 leading-relaxed">
                This section requires JNARDDC Administrator privileges. Log in with an administrator account (e.g. <span className="font-mono text-amber-300">admin@jnarddc.gov.in</span>) to access compliance verification and governance tools.
              </p>
              <button
                onClick={() => setActiveTab("dashboard")}
                className="bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-bold px-4 py-2.5 rounded-xl shadow-md transition"
              >
                Return to Recycler Dashboard
              </button>
            </div>
          ) : (
            <>
              {activeTab === "dashboard" && <RecyclerDashboardView />}
              {activeTab === "inbox" && <MatchedLotsInboxView />}
              {activeTab === "handover" && <HandoverConfirmationView />}
              {activeTab === "downstream" && <DownstreamTrackingView />}
              {activeTab === "profile" && <RecyclerProfileView />}
              {activeTab === "verification" && <AdminVerificationQueueView />}
              {activeTab === "expiry" && <AdminExpiryAlertsView />}
              {activeTab === "price_board" && <AdminPriceBoardView />}
              {activeTab === "anomalies" && <AdminAnomalyReviewView />}
              {activeTab === "analytics" && <AdminAnalyticsView />}
            </>
          )}
        </main>
      </div>

      {/* Mobile Bottom Navigation Bar (< 768px screens) */}
      <nav className="md:hidden fixed bottom-0 left-0 right-0 bg-slate-900/95 backdrop-blur border-t border-slate-800 z-40 px-2 py-1.5 flex justify-around">
        {user.role === "public" ? (
          <>
            <button
              onClick={() => setActiveTab("citizen_dashboard")}
              className={`flex flex-col items-center py-1 px-2 rounded-lg text-[10px] font-bold ${
                activeTab === "citizen_dashboard" ? "text-teal-400" : "text-slate-400"
              }`}
            >
              <Truck className="w-5 h-5" />
              <span>Book</span>
            </button>
            <button
              onClick={() => setActiveTab("citizen_pickups")}
              className={`flex flex-col items-center py-1 px-2 rounded-lg text-[10px] font-bold ${
                activeTab === "citizen_pickups" ? "text-teal-400" : "text-slate-400"
              }`}
            >
              <Clock className="w-5 h-5" />
              <span>Track</span>
            </button>
            <button
              onClick={() => setActiveTab("citizen_prices")}
              className={`flex flex-col items-center py-1 px-2 rounded-lg text-[10px] font-bold ${
                activeTab === "citizen_prices" ? "text-teal-400" : "text-slate-400"
              }`}
            >
              <TrendingUp className="w-5 h-5" />
              <span>Prices</span>
            </button>
            <button
              onClick={() => setActiveTab("citizen_impact")}
              className={`flex flex-col items-center py-1 px-2 rounded-lg text-[10px] font-bold ${
                activeTab === "citizen_impact" ? "text-teal-400" : "text-slate-400"
              }`}
            >
              <Award className="w-5 h-5" />
              <span>Impact</span>
            </button>
          </>
        ) : (
          <>
            <button
              onClick={() => setActiveTab("dashboard")}
              className={`flex flex-col items-center py-1 px-2 rounded-lg text-[10px] font-bold ${
                activeTab === "dashboard" ? "text-emerald-400" : "text-slate-400"
              }`}
            >
              <LayoutDashboard className="w-5 h-5" />
              <span>Home</span>
            </button>
            <button
              onClick={() => setActiveTab("inbox")}
              className={`flex flex-col items-center py-1 px-2 rounded-lg text-[10px] font-bold ${
                activeTab === "inbox" ? "text-emerald-400" : "text-slate-400"
              }`}
            >
              <Inbox className="w-5 h-5" />
              <span>Inbox</span>
            </button>
            <button
              onClick={() => setActiveTab("handover")}
              className={`flex flex-col items-center py-1 px-2 rounded-lg text-[10px] font-bold ${
                activeTab === "handover" ? "text-emerald-400" : "text-slate-400"
              }`}
            >
              <QrCode className="w-5 h-5" />
              <span>Handover</span>
            </button>
            <button
              onClick={() => setActiveTab("anomalies")}
              className={`flex flex-col items-center py-1 px-2 rounded-lg text-[10px] font-bold ${
                activeTab === "anomalies" ? "text-amber-400" : "text-slate-400"
              }`}
            >
              <ShieldAlert className="w-5 h-5" />
              <span>Audit</span>
            </button>
            <button
              onClick={() => setActiveTab("profile")}
              className={`flex flex-col items-center py-1 px-2 rounded-lg text-[10px] font-bold ${
                activeTab === "profile" ? "text-emerald-400" : "text-slate-400"
              }`}
            >
              <FileBadge className="w-5 h-5" />
              <span>Profile</span>
            </button>
          </>
        )}
      </nav>
    </div>
  );
}
