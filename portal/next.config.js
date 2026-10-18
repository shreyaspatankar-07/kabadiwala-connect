/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // NOTE: "standalone" output is for Docker/self-hosted only.
  // Vercel uses its own native Next.js runtime — no output mode needed.
};

module.exports = nextConfig;
