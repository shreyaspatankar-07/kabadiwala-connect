"use client";

import React, { createContext, useContext, useState, useEffect } from "react";
import { UserRole, UserSession } from "../lib/types";

interface AuthContextType {
  user: UserSession | null;
  login: (email: string, role: UserRole, password?: string, customUser?: Partial<UserSession>) => Promise<void>;
  register: (
    name: string,
    email: string,
    password: string,
    phone: string,
    address: string
  ) => Promise<boolean>;
  logout: () => void;
  switchRole: (role: UserRole) => void;
}

const defaultPublicUser: UserSession = {
  id: "PUB-01",
  email: "citizen@mumbai.gov.in",
  name: "Sunita Sharma (Citizen)",
  role: "public",
  phone: "+91 98765 43210",
  address: "Bandra West, Mumbai",
  isVerified: true,
};

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
  // Start logged OUT by default so user always sees the role selection & login screen first
  const [user, setUser] = useState<UserSession | null>(null);

  useEffect(() => {
    const saved = localStorage.getItem("kc_portal_session");
    if (saved) {
      try {
        setUser(JSON.parse(saved));
      } catch {
        setUser(null);
      }
    }
  }, []);

  const login = async (
    email: string,
    role: UserRole,
    password?: string,
    customUser?: Partial<UserSession>
  ): Promise<void> => {
    const cleanEmail = email.trim().toLowerCase();

    let effectiveRole: UserRole = role;
    if (cleanEmail.includes("admin") || cleanEmail === "admin@jnarddc.gov.in") {
      effectiveRole = "admin";
    } else if (cleanEmail.includes("citizen") || cleanEmail.includes("public")) {
      effectiveRole = "public";
    }

    let token: string | undefined;
    if (password) {
      try {
        const apiBase = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000/api/v1";
        const res = await fetch(`${apiBase}/auth/login`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ email: cleanEmail, password }),
        });
        if (res.ok) {
          const data = await res.json();
          token = data.access_token;
        }
      } catch {
        // Fallback to local offline session gracefully
      }
    }

    let newUser: UserSession;
    if (effectiveRole === "admin") {
      newUser = { ...defaultAdminUser, email: cleanEmail || "admin@jnarddc.gov.in", token, ...customUser };
    } else if (effectiveRole === "public") {
      newUser = { ...defaultPublicUser, email: cleanEmail || "citizen@mumbai.gov.in", token, ...customUser };
    } else {
      newUser = { ...defaultRecyclerUser, email: cleanEmail || "recycler@ecorecycle.in", token, ...customUser };
    }

    setUser(newUser);
    localStorage.setItem("kc_portal_session", JSON.stringify(newUser));
  };

  const register = async (
    name: string,
    email: string,
    password: string,
    phone: string,
    address: string
  ): Promise<boolean> => {
    try {
      const apiBase = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000/api/v1";
      const res = await fetch(`${apiBase}/auth/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name,
          email,
          password,
          phone,
          address,
          role: "public",
        }),
      });

      const data = await res.json().catch(() => ({}));
      const newUser: UserSession = {
        id: `PUB-${Date.now().toString().slice(-4)}`,
        email,
        name: name || "Verified Citizen",
        role: "public",
        phone,
        address,
        token: data.access_token,
        isVerified: true,
      };

      setUser(newUser);
      localStorage.setItem("kc_portal_session", JSON.stringify(newUser));
      return true;
    } catch {
      const newUser: UserSession = {
        id: `PUB-${Date.now().toString().slice(-4)}`,
        email,
        name: name || "Verified Citizen",
        role: "public",
        phone,
        address,
        isVerified: true,
      };

      setUser(newUser);
      localStorage.setItem("kc_portal_session", JSON.stringify(newUser));
      return true;
    }
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem("kc_portal_session");
  };

  const switchRole = (role: UserRole) => {
    let newUser = defaultRecyclerUser;
    if (role === "admin") newUser = defaultAdminUser;
    if (role === "public") newUser = defaultPublicUser;

    setUser(newUser);
    localStorage.setItem("kc_portal_session", JSON.stringify(newUser));
  };

  return (
    <AuthContext.Provider value={{ user, login, register, logout, switchRole }}>
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
