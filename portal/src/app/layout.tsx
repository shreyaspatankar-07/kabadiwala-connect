import type { Metadata } from "next";
import "./globals.css";
import { AuthProvider } from "../context/AuthContext";
import { LanguageProvider } from "../context/LanguageContext";

export const metadata: Metadata = {
  title: "Kabadiwala Connect | JNARDDC EPR Recycler & Admin Portal",
  description:
    "Vernacular, low-literacy offline-tolerant platform connecting informal e-waste collectors with authorized recyclers under E-Waste Rules 2022.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="mr">
      <body className="antialiased min-h-screen bg-slate-950 text-slate-100 selection:bg-emerald-500 selection:text-white">
        <LanguageProvider>
          <AuthProvider>{children}</AuthProvider>
        </LanguageProvider>
      </body>
    </html>
  );
}
