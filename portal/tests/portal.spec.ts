import { test, expect } from "@playwright/test";

test.describe("Kabadiwala Connect - Recycler & Admin Portal E2E Tests", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    // Switch to English language for predictable test assertions
    const enBtn = page.getByTestId("btn-lang-en");
    if (await enBtn.isVisible()) {
      await enBtn.click();
    }
  });

  test("1. Recycler login & dashboard overview", async ({ page }) => {
    // If login screen is shown, click demo recycler
    const demoRecyclerBtn = page.getByTestId("btn-demo-recycler");
    if (await demoRecyclerBtn.isVisible()) {
      await demoRecyclerBtn.click();
    }

    // Verify Recycler Dashboard elements
    await expect(page.locator("text=Maharashtra Eco-Recyclers Pvt Ltd")).toBeVisible();
    await expect(page.locator("text=EPR Status")).toBeVisible();
    await expect(page.locator("text=Total E-Waste (This Month)")).toBeVisible();
  });

  test("2. Matched lots inbox: Accept and Counter-Offer actions", async ({ page }) => {
    // Ensure logged in as recycler
    const demoRecyclerBtn = page.getByTestId("btn-demo-recycler");
    if (await demoRecyclerBtn.isVisible()) {
      await demoRecyclerBtn.click();
    }

    // Switch to Inbox tab
    await page.getByTestId("nav-tab-inbox").click();

    // Verify lots are visible
    await expect(page.locator("text=Incoming matched e-waste lots")).toBeVisible();
    const lotCard = page.getByTestId("lot-card-LOT-M1");
    await expect(lotCard).toBeVisible();

    // Click Accept on LOT-M1
    const acceptBtn = page.getByTestId("btn-accept-LOT-M1");
    if (await acceptBtn.isVisible()) {
      await acceptBtn.click();
      await expect(page.locator("text=Lot LOT-M1 accepted")).toBeVisible();
    }

    // Click Counter-Offer on LOT-M2
    const counterBtn = page.getByTestId("btn-counter-LOT-M2");
    if (await counterBtn.isVisible()) {
      await counterBtn.click();
      await expect(page.locator("text=Propose Counter-Offer")).toBeVisible();
      await page.getByTestId("submit-counter-offer").click();
      await expect(page.locator("text=Counter-offer")).toBeVisible();
    }
  });

  test("3. Handover verification with live weight mismatch warning (>10%)", async ({ page }) => {
    // Ensure logged in as recycler
    const demoRecyclerBtn = page.getByTestId("btn-demo-recycler");
    if (await demoRecyclerBtn.isVisible()) {
      await demoRecyclerBtn.click();
    }

    // Switch to Handover tab
    await page.getByTestId("nav-tab-handover").click();

    // Verify Handover form
    await expect(page.locator("text=Verify digital handover")).toBeVisible();

    // Input measured weight differing by >10% (e.g. 15.0 kg vs estimated 12.5 kg = 20% mismatch)
    const weightInput = page.getByTestId("input-measured-weight");
    await weightInput.fill("15.0");

    // Verify Weight Mismatch Warning banner appears
    await expect(page.getByTestId("weight-mismatch-warning")).toBeVisible();
    await expect(page.locator("text=Weight Mismatch Warning (20.0%)")).toBeVisible();

    // Confirm Handover
    await page.getByTestId("btn-confirm-handover").click();
    await expect(page.locator("text=REF NO:")).toBeVisible();
    await expect(page.locator("text=DISPUTED")).toBeVisible();
  });

  test("4. Admin verification queue: Approve recycler", async ({ page }) => {
    // Log in as Admin
    const demoAdminBtn = page.getByTestId("btn-demo-admin");
    if (await demoAdminBtn.isVisible()) {
      await demoAdminBtn.click();
    } else {
      // If already logged in as recycler, use demo admin switch
      await page.getByTestId("nav-tab-verification").click();
    }

    // Switch to Admin Verification tab
    await page.getByTestId("nav-tab-verification").click();

    // Verify Pending Recycler Card
    const recCard = page.getByTestId("recycler-verification-REC-P01");
    await expect(recCard).toBeVisible();

    // Click Approve
    const approveBtn = page.getByTestId("btn-approve-REC-P01");
    if (await approveBtn.isVisible()) {
      await approveBtn.click();
      await expect(page.locator("text=status updated to: VERIFIED")).toBeVisible();
    }
  });

  test("5. Admin anomaly review queue: Resolve and Escalate", async ({ page }) => {
    // Log in as Admin
    const demoAdminBtn = page.getByTestId("btn-demo-admin");
    if (await demoAdminBtn.isVisible()) {
      await demoAdminBtn.click();
    }

    // Switch to Anomaly Review tab
    await page.getByTestId("nav-tab-anomalies").click();

    // Verify Anomaly Card
    const anomCard = page.getByTestId("anomaly-card-ANOM-01");
    await expect(anomCard).toBeVisible();
    await expect(page.locator("text=IMPLAUSIBLE_WEIGHT")).toBeVisible();

    // Click Resolve
    const resolveBtn = page.getByTestId("btn-resolve-ANOM-01");
    if (await resolveBtn.isVisible()) {
      await resolveBtn.click();
      await expect(page.locator("text=Anomaly ANOM-01 resolved and cleared")).toBeVisible();
    }
  });
});
