"use client";

import React from "react";
import { useAuth } from "../context/AuthContext";
import { useLanguage } from "../context/LanguageContext";
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
  Clock,
  Award,
} from "lucide-react";

interface SidebarProps {
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

export function Sidebar({ activeTab, setActiveTab }: SidebarProps) {
  const { user } = useAuth();
  const { t } = useLanguage();

  if (!user) return null;

  const citizenNavItems = [
    { id: "citizen_dashboard", label: t.navCitizenPickup, icon: Truck },
    { id: "citizen_pickups", label: t.navCitizenTracking, icon: Clock },
    { id: "citizen_prices", label: t.navCitizenPriceGuide, icon: TrendingUp },
    { id: "citizen_impact", label: t.navCitizenImpact, icon: Award },
  ];

  const recyclerNavItems = [
    { id: "dashboard", label: t.navDashboard, icon: LayoutDashboard },
    { id: "inbox", label: t.navInbox, icon: Inbox },
    { id: "handover", label: t.navHandover, icon: QrCode },
    { id: "downstream", label: t.navDownstream, icon: Truck },
    { id: "profile", label: t.navProfile, icon: FileBadge },
  ];

  const adminNavItems = [
    { id: "verification", label: t.navVerificationQueue, icon: UserCheck },
    { id: "expiry", label: t.navExpiryAlerts, icon: AlertTriangle },
    { id: "price_board", label: t.navPriceBoard, icon: TrendingUp },
    { id: "anomalies", label: t.navAnomalies, icon: ShieldAlert },
    { id: "analytics", label: t.navAnalytics, icon: BarChart3 },
  ];

  return (
    <aside className="w-64 bg-slate-900 border-r border-slate-800 flex-shrink-0 flex flex-col justify-between p-4 hidden md:flex">
      <div className="space-y-6">
        {/* Citizen Navigation Group (Visible if public or as role) */}
        {user.role === "public" && (
          <div>
            <h2 className="px-3 text-xs font-bold uppercase tracking-wider text-teal-400 mb-2">
              {t.rolePublic}
            </h2>
            <nav className="space-y-1">
              {citizenNavItems.map((item) => {
                const Icon = item.icon;
                const isActive = activeTab === item.id;
                return (
                  <button
                    key={item.id}
                    data-testid={`nav-tab-${item.id}`}
                    onClick={() => setActiveTab(item.id)}
                    className={`w-full flex items-center space-x-3 px-3 py-2.5 rounded-xl font-semibold text-sm transition-all ${
                      isActive
                        ? "bg-teal-600 text-white shadow-md shadow-teal-900/40"
                        : "text-slate-300 hover:bg-slate-800 hover:text-white"
                    }`}
                  >
                    <Icon className={`w-5 h-5 ${isActive ? "text-white" : "text-teal-400"}`} />
                    <span>{item.label}</span>
                  </button>
                );
              })}
            </nav>
          </div>
        )}

        {/* Recycler Navigation Group */}
        {(user.role === "recycler" || user.role === "admin") && (
          <div>
            <h2 className="px-3 text-xs font-bold uppercase tracking-wider text-slate-400 mb-2 flex items-center justify-between">
              <span>{t.roleRecycler}</span>
            </h2>
            <nav className="space-y-1">
              {recyclerNavItems.map((item) => {
                const Icon = item.icon;
                const isActive = activeTab === item.id;
                return (
                  <button
                    key={item.id}
                    data-testid={`nav-tab-${item.id}`}
                    onClick={() => setActiveTab(item.id)}
                    className={`w-full flex items-center space-x-3 px-3 py-2.5 rounded-xl font-semibold text-sm transition-all ${
                      isActive
                        ? "bg-emerald-600 text-white shadow-md shadow-emerald-900/40"
                        : "text-slate-300 hover:bg-slate-800 hover:text-white"
                    }`}
                  >
                    <Icon className={`w-5 h-5 ${isActive ? "text-white" : "text-emerald-400"}`} />
                    <span>{item.label}</span>
                  </button>
                );
              })}
            </nav>
          </div>
        )}

        {/* Admin Navigation Group */}
        {user.role === "admin" && (
          <div>
            <h2 className="px-3 text-xs font-bold uppercase tracking-wider text-amber-400/90 mb-2 flex items-center justify-between">
              <span>{t.roleAdmin}</span>
            </h2>
            <nav className="space-y-1">
              {adminNavItems.map((item) => {
                const Icon = item.icon;
                const isActive = activeTab === item.id;
                return (
                  <button
                    key={item.id}
                    data-testid={`nav-tab-${item.id}`}
                    onClick={() => setActiveTab(item.id)}
                    className={`w-full flex items-center space-x-3 px-3 py-2.5 rounded-xl font-semibold text-sm transition-all ${
                      isActive
                        ? "bg-amber-600 text-white shadow-md shadow-amber-900/40"
                        : "text-slate-300 hover:bg-slate-800 hover:text-white"
                    }`}
                  >
                    <Icon className={`w-5 h-5 ${isActive ? "text-white" : "text-amber-400"}`} />
                    <span>{item.label}</span>
                  </button>
                );
              })}
            </nav>
          </div>
        )}
      </div>

      {/* Footer Info */}
      <div className="pt-4 border-t border-slate-800">
        <div className="bg-slate-800/80 rounded-xl p-3 border border-slate-700">
          <div className="flex items-center space-x-2">
            <span className="w-2.5 h-2.5 rounded-full bg-emerald-400 animate-pulse"></span>
            <p className="text-xs font-bold text-slate-200">E-Waste Rules 2022</p>
          </div>
          <p className="text-[11px] text-slate-400 mt-1">
            SIH PS 26229 Compliant System
          </p>
        </div>
      </div>
    </aside>
  );
}
