"use client";

import React, { useState } from "react";
import { useAuth } from "../context/AuthContext";
import { useLanguage } from "../context/LanguageContext";
import { Navbar } from "../components/Navbar";
import { Sidebar } from "../components/Sidebar";
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
} from "lucide-react";

export default function PortalPage() {
  const { user, login } = useAuth();
  const { t } = useLanguage();
  const [activeTab, setActiveTab] = useState<string>("dashboard");

  const [email, setEmail] = useState("recycler@ecorecycle.com");
  const [password, setPassword] = useState("password123");

  const handleLogin = (role: "recycler" | "admin") => {
    login(email, role);
    const targetRole = email.includes("admin") ? "admin" : role;
    setActiveTab(targetRole === "admin" ? "verification" : "dashboard");
  };

  // If user is not logged in, render high-contrast login screen
  if (!user) {
    return (
      <div className="min-h-screen bg-slate-950 flex flex-col justify-between">
        <Navbar />
        <main className="flex-1 flex items-center justify-center p-4">
          <div className="bg-slate-900 border border-slate-800 rounded-3xl p-8 max-w-md w-full shadow-2xl space-y-6">
            <div className="text-center space-y-2">
              <div className="w-14 h-14 bg-emerald-600 rounded-2xl mx-auto flex items-center justify-center font-black text-2xl text-white shadow-lg shadow-emerald-900/50">
                KC
              </div>
              <h1 className="text-2xl font-black text-white">{t.loginTitle}</h1>
              <p className="text-xs text-slate-400">{t.loginSubtitle}</p>
            </div>

            <form
              onSubmit={(e) => {
                e.preventDefault();
                handleLogin(email.toLowerCase().includes("admin") ? "admin" : "recycler");
              }}
              className="space-y-4"
            >
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

              <button
                type="submit"
                data-testid="btn-login-submit"
                className="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-extrabold py-3 rounded-xl shadow-lg shadow-emerald-900/40 text-sm transition"
              >
                {t.btnSignIn}
              </button>
            </form>

            {/* Quick Demo Logins */}
            <div className="pt-4 border-t border-slate-800 space-y-2">
              <span className="text-[11px] font-bold text-slate-500 uppercase tracking-wider block text-center">
                {t.quickDemoLogin}
              </span>
              <div className="grid grid-cols-2 gap-2">
                <button
                  type="button"
                  data-testid="btn-demo-recycler"
                  onClick={() => {
                    setEmail("recycler@ecorecycle.in");
                    setPassword("recycler123");
                    handleLogin("recycler");
                  }}
                  className="bg-slate-800 hover:bg-slate-750 border border-slate-700 text-emerald-400 font-bold py-2 px-3 rounded-xl text-xs flex items-center justify-center space-x-1 transition"
                >
                  <Building2 className="w-3.5 h-3.5" />
                  <span>Recycler Demo</span>
                </button>
                <button
                  type="button"
                  data-testid="btn-demo-admin"
                  onClick={() => {
                    setEmail("admin@jnarddc.gov.in");
                    setPassword("admin123");
                    handleLogin("admin");
                  }}
                  className="bg-slate-800 hover:bg-slate-750 border border-slate-700 text-amber-400 font-bold py-2 px-3 rounded-xl text-xs flex items-center justify-center space-x-1 transition"
                >
                  <ShieldCheck className="w-3.5 h-3.5" />
                  <span>Admin Demo</span>
                </button>
              </div>
            </div>
          </div>
        </main>
      </div>
    );
  }

  // Admin tabs list for role-based protection
  const adminTabs = ["verification", "expiry", "price_board", "anomalies", "analytics"];
  const isAccessForbidden = user.role !== "admin" && adminTabs.includes(activeTab);

  // Render main portal shell with sidebar and views
  return (
    <div className="min-h-screen bg-slate-950 flex flex-col">
      <Navbar />

      <div className="flex-1 flex overflow-hidden">
        {/* Responsive Desktop Sidebar */}
        <Sidebar activeTab={activeTab} setActiveTab={setActiveTab} />

        {/* Main Content Area */}
        <main className="flex-1 overflow-y-auto p-4 sm:p-6 lg:p-8 max-w-7xl mx-auto w-full pb-20 md:pb-8">
          {isAccessForbidden ? (
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
      </nav>
    </div>
  );
}
