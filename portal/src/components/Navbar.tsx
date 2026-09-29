"use client";

import React from "react";
import { useAuth } from "../context/AuthContext";
import { useLanguage } from "../context/LanguageContext";
import { Locale } from "../lib/i18n";
import { ShieldCheck, LogOut, Globe, UserCheck, RefreshCw } from "lucide-react";

export function Navbar() {
  const { user, switchRole, logout } = useAuth();
  const { locale, setLocale, t } = useLanguage();

  return (
    <header className="bg-slate-900 text-white border-b border-slate-800 sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
        {/* Brand */}
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 rounded-xl bg-emerald-600 flex items-center justify-center font-black text-xl shadow-lg shadow-emerald-900/50">
            KC
          </div>
          <div>
            <div className="flex items-center space-x-2">
              <span className="font-extrabold text-lg tracking-tight bg-gradient-to-r from-emerald-400 to-teal-200 bg-clip-text text-transparent">
                {t.brandName}
              </span>
              <span className="text-xs px-2 py-0.5 rounded-full bg-emerald-950 text-emerald-300 border border-emerald-700/60 font-medium">
                EPR Portal
              </span>
            </div>
            <p className="text-xs text-slate-400 hidden sm:block">
              {t.ministry}
            </p>
          </div>
        </div>

        {/* Actions */}
        <div className="flex items-center space-x-3">
          {/* Language Selector */}
          <div className="flex items-center bg-slate-800 rounded-lg p-1 border border-slate-700">
            <Globe className="w-4 h-4 text-slate-400 ml-1.5 mr-1" />
            {(["mr", "hi", "en"] as Locale[]).map((l) => (
              <button
                key={l}
                data-testid={`btn-lang-${l}`}
                onClick={() => setLocale(l)}
                className={`px-2.5 py-1 text-xs font-bold rounded-md transition-all ${
                  locale === l
                    ? "bg-emerald-600 text-white shadow"
                    : "text-slate-300 hover:text-white"
                }`}
              >
                {l === "mr" ? "मराठी" : l === "hi" ? "हिंदी" : "EN"}
              </button>
            ))}
          </div>

          {/* Role Switcher */}
          {user && (
            <div className="flex items-center bg-slate-800 rounded-lg p-1 border border-slate-700">
              <button
                data-testid="btn-role-switcher"
                onClick={() => switchRole(user.role === "recycler" ? "admin" : "recycler")}
                className="flex items-center space-x-1.5 text-xs font-semibold px-2.5 py-1 rounded-md text-amber-300 hover:bg-slate-700 transition"
                title="Switch Role for Demo testing"
              >
                <RefreshCw className="w-3.5 h-3.5" />
                <span className="hidden sm:inline">Role:</span>
                <span className="capitalize font-bold text-white">
                  {user.role === "admin" ? t.roleAdmin : t.roleRecycler}
                </span>
              </button>
            </div>
          )}

          {/* User Profile / Logout */}
          {user ? (
            <div className="flex items-center space-x-2 pl-2 border-l border-slate-700">
              <div className="w-8 h-8 rounded-full bg-emerald-800 border border-emerald-600 flex items-center justify-center text-xs font-bold text-emerald-200">
                {user.name.substring(0, 2).toUpperCase()}
              </div>
              <button
                onClick={logout}
                className="p-1.5 text-slate-400 hover:text-red-400 transition rounded-lg hover:bg-slate-800"
                title={t.btnSignOut}
              >
                <LogOut className="w-4 h-4" />
              </button>
            </div>
          ) : (
            <button
              data-testid="btn-nav-login"
              className="px-3.5 py-1.5 bg-emerald-600 hover:bg-emerald-500 text-white rounded-xl text-xs font-extrabold transition shadow shadow-emerald-950"
            >
              Login
            </button>
          )}
        </div>
      </div>
    </header>
  );
}
