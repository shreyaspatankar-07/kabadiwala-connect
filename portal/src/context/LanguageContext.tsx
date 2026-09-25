"use client";

import React, { createContext, useContext, useState, useEffect } from "react";
import { Locale, translations } from "../lib/i18n";

interface LanguageContextType {
  locale: Locale;
  setLocale: (l: Locale) => void;
  t: typeof translations.en;
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

export function LanguageProvider({ children }: { children: React.ReactNode }) {
  const [locale, setLocaleState] = useState<Locale>("mr"); // Marathi default per AGENTS.md

  useEffect(() => {
    const saved = localStorage.getItem("kc_portal_locale") as Locale;
    if (saved && (saved === "en" || saved === "mr" || saved === "hi")) {
      setLocaleState(saved);
    }
  }, []);

  const setLocale = (l: Locale) => {
    setLocaleState(l);
    localStorage.setItem("kc_portal_locale", l);
  };

  const t = translations[locale] || translations.en;

  return (
    <LanguageContext.Provider value={{ locale, setLocale, t }}>
      {children}
    </LanguageContext.Provider>
  );
}

export function useLanguage() {
  const ctx = useContext(LanguageContext);
  if (!ctx) {
    throw new Error("useLanguage must be used within LanguageProvider");
  }
  return ctx;
}
