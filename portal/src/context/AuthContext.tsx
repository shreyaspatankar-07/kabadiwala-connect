"use client";

import React, { createContext, useContext, useState, useEffect } from "react";
import { UserRole, UserSession } from "../lib/types";

interface AuthContextType {
  user: UserSession | null;
  login: (email: string, role: UserRole) => void;
  logout: () => void;
  switchRole: (role: UserRole) => void;
}

const defaultRecyclerUser: UserSession = {
  id: "REC-01",
  email: "recycler@ecorecycle.in",
  name: "Maharashtra Eco-Recyclers",
  role: "recycler",
  recyclerId: "REC-ECO-01",
  authorizationNumber: "MPCB/EPR/2024/REC-4019",
  isVerified: true,
};

const defaultAdminUser: UserSession = {
  id: "ADM-01",
  email: "admin@jnarddc.gov.in",
  name: "JNARDDC Admin Compliance Officer",
  role: "admin",
  isVerified: true,
};

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<UserSession | null>(defaultRecyclerUser);

  useEffect(() => {
    const saved = localStorage.getItem("kc_portal_session");
    if (saved) {
      try {
        setUser(JSON.parse(saved));
      } catch {
        setUser(defaultRecyclerUser);
      }
    }
  }, []);

  const login = (email: string, role: UserRole) => {
    const cleanEmail = email.trim().toLowerCase();
    const effectiveRole: UserRole =
      cleanEmail.includes("admin") || cleanEmail === "admin@jnarddc.gov.in"
        ? "admin"
        : role;

    const newUser: UserSession =
      effectiveRole === "admin"
        ? { ...defaultAdminUser, email: cleanEmail || "admin@jnarddc.gov.in" }
        : { ...defaultRecyclerUser, email: cleanEmail || "recycler@ecorecycle.in" };
    setUser(newUser);
    localStorage.setItem("kc_portal_session", JSON.stringify(newUser));
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem("kc_portal_session");
  };

  const switchRole = (role: UserRole) => {
    const newUser = role === "admin" ? defaultAdminUser : defaultRecyclerUser;
    setUser(newUser);
    localStorage.setItem("kc_portal_session", JSON.stringify(newUser));
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, switchRole }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) {
    throw new Error("useAuth must be used within AuthProvider");
  }
  return ctx;
}
