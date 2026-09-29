import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./scripts",
  testMatch: ["demo_walkthrough.spec.ts", "**/*.spec.ts"],
  timeout: 180000,
  fullyParallel: false,
  workers: 1,
  reporter: "list",
  outputDir: "./test-results",
  use: {
    baseURL: "http://localhost:3000",
    viewport: { width: 1280, height: 720 },
    video: "on",
    screenshot: "on",
    headless: false,
    launchOptions: {
      slowMo: 500,
    },
    trace: "retain-on-failure",
  },
  webServer: {
    command: "npm run dev",
    url: "http://localhost:3000",
    reuseExistingServer: true,
    timeout: 120000,
  },
  projects: [
    {
      name: "chromium",
      use: {
        ...devices["Desktop Chrome"],
        viewport: { width: 1280, height: 720 },
        video: "on",
        screenshot: "on",
        headless: false,
        launchOptions: {
          slowMo: 500,
        },
      },
    },
  ],
});
