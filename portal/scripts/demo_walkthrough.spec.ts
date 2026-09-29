import { test, expect } from "@playwright/test";

test.describe("Portal Demo Walkthrough Video Recording", () => {
  test("Complete Recycler & Admin Demo Flow", async ({ page, context }) => {
    // Set 3 minute timeout for comprehensive demo pacing
    test.setTimeout(180000);

    // Ensure pristine unauthenticated session
    await context.clearCookies();
    await page.goto("http://localhost:3000");
    await page.evaluate(() => localStorage.clear());
    await page.reload();

    // =========================================================================
    // PART 1 - Recycler login and inbox:
    // =========================================================================
    // 1. Navigate to http://localhost:3000
    // (Already navigated & reloaded)

    // 2. Wait 3 seconds on landing page
    await page.waitForTimeout(3000);

    // 3. Click login button (if top nav login button exists, click it)
    const navLoginBtn = page.locator('[data-testid="btn-nav-login"]');
    if (await navLoginBtn.isVisible()) {
      await navLoginBtn.click();
      await page.waitForTimeout(500);
    }

    // 4. Fill email: recycler@demo.com
    const emailInput = page.locator('[data-testid="input-email"]');
    await emailInput.fill("recycler@demo.com");
    await page.waitForTimeout(500);

    // 5. Fill password: demo1234
    const passwordInput = page.locator('[data-testid="input-password"]');
    await passwordInput.fill("demo1234");
    await page.waitForTimeout(500);

    // 6. Click submit
    const submitBtn = page.locator('[data-testid="btn-login-submit"]');
    await submitBtn.click();

    // 7. Wait 3 seconds on dashboard
    await page.waitForTimeout(3000);

    // 8. Click Lot Inbox in sidebar
    await page.locator('[data-testid="nav-tab-inbox"]').click();

    // 9. Wait 3 seconds showing matched lots list
    await page.waitForTimeout(3000);

    // 10. Click Accept on the first lot card
    const acceptBtn = page.locator('[data-testid^="btn-accept-"]').first();
    await expect(acceptBtn).toBeVisible();
    await acceptBtn.click();

    // 11. Wait 3 seconds showing acceptance confirmation
    await page.waitForTimeout(3000);

    // =========================================================================
    // PART 2 - Handover confirmation:
    // =========================================================================
    // 12. Click Handover Confirmation in sidebar
    await page.locator('[data-testid="nav-tab-handover"]').click();

    // 13. Wait 2 seconds
    await page.waitForTimeout(2000);

    // 14. Fill reference code field with: A7K9P2
    const codeInput = page.locator('[data-testid="input-handover-code"]');
    await codeInput.fill("A7K9P2");

    // 15. Wait 2 seconds
    await page.waitForTimeout(2000);

    // 16. Fill measured weight: 5.2
    const weightInput = page.locator('[data-testid="input-measured-weight"]');
    await weightInput.fill("5.2");

    // 17. Fill final price: 2100
    const priceInput = page.locator('[data-testid="input-final-price"]');
    await priceInput.fill("2100");

    // 18. Wait 2 seconds showing weight mismatch calculation
    await page.waitForTimeout(2000);

    // 19. Click Cash payment option
    const cashBtn = page.getByRole("button", { name: /cash/i });
    if (await cashBtn.isVisible()) {
      await cashBtn.click();
    }

    // 20. Wait 2 seconds
    await page.waitForTimeout(2000);

    // 21. Click Confirm Handover button
    const confirmBtn = page.locator('[data-testid="btn-confirm-handover"]');
    await confirmBtn.click();

    // 22. Wait 4 seconds showing receipt
    await page.waitForTimeout(4000);

    // =========================================================================
    // PART 3 - Downstream status:
    // =========================================================================
    // 23. Click Downstream Tracking in sidebar
    await page.locator('[data-testid="nav-tab-downstream"]').click();

    // 24. Wait 2 seconds
    await page.waitForTimeout(2000);

    // 25. Select Dismantled from status dropdown
    const stageSelect = page.locator('select[data-testid^="select-stage-"]').first();
    await stageSelect.selectOption("dismantled");

    // 26. Click Update Status button
    const updateStatusBtn = page.locator('button[data-testid^="btn-update-status-"]').first();
    await updateStatusBtn.click();

    // 27. Wait 3 seconds showing 4-step timeline with step 2 checked
    await page.waitForTimeout(3000);

    // =========================================================================
    // PART 4 - Recycler dashboard:
    // =========================================================================
    // 28. Click Dashboard in sidebar
    await page.locator('[data-testid="nav-tab-dashboard"]').click();

    // 29. Wait 4 seconds showing volume, spend, rates, pending payments
    await page.waitForTimeout(4000);

    // =========================================================================
    // PART 5 - Switch to Admin view:
    // =========================================================================
    // 30. Click role switcher to Admin
    const roleSwitcher = page.locator('[data-testid="btn-role-switcher"]');
    await roleSwitcher.click();

    // 31. Wait 2 seconds
    await page.waitForTimeout(2000);

    // =========================================================================
    // PART 6 - Admin recycler verification:
    // =========================================================================
    // 32. Click Recycler Verification Queue
    await page.locator('[data-testid="nav-tab-verification"]').click();

    // 33. Wait 3 seconds showing pending recyclers list
    await page.waitForTimeout(3000);

    // 34. Click Approve on first recycler
    const approveBtn = page.locator('button[data-testid^="btn-approve-"]').first();
    await approveBtn.click();

    // 35. Wait 3 seconds showing approved status
    await page.waitForTimeout(3000);

    // =========================================================================
    // PART 7 - Anomaly review:
    // =========================================================================
    // 36. Click Anomaly Review Queue
    await page.locator('[data-testid="nav-tab-anomalies"]').click();

    // 37. Wait 4 seconds showing flagged transactions with reasons (price_outlier, weight_implausible, rapid_burst)
    await page.waitForTimeout(4000);

    // 38. Click Resolve on first anomaly
    const resolveBtn = page.locator('button[data-testid^="btn-resolve-"]').first();
    await resolveBtn.click();

    // 39. Wait 3 seconds
    await page.waitForTimeout(3000);

    // =========================================================================
    // PART 8 - Analytics:
    // =========================================================================
    // 40. Click Analytics Dashboard
    await page.locator('[data-testid="nav-tab-analytics"]').click();

    // 41. Wait 5 seconds showing bar chart, line chart, earnings comparison, data quality score 91.7/100
    await page.waitForTimeout(5000);

    // 42. Wait 3 seconds on the earnings lift showing +70% number
    const earningsLift = page.locator('[data-testid="earnings-lift-metric"]');
    await earningsLift.scrollIntoViewIfNeeded();
    await page.waitForTimeout(3000);

    // =========================================================================
    // PART 9 - Price board override:
    // =========================================================================
    // 43. Click Price Board Management
    await page.locator('[data-testid="nav-tab-price_board"]').click();

    // 44. Wait 3 seconds showing current rates table
    await page.waitForTimeout(3000);

    // 45. Click Override on PCB Mumbai row
    const pcbMumbaiOverride = page.locator('[data-testid="btn-override-PCB-Mumbai"]');
    if (await pcbMumbaiOverride.isVisible()) {
      await pcbMumbaiOverride.click();
    } else {
      const anyOverride = page.getByRole("button", { name: /override/i }).first();
      await anyOverride.click();
    }
    await page.waitForTimeout(1000);

    // 46. Fill new rate: 480
    const overridePriceInput = page.locator('[data-testid="input-override-price"]');
    await overridePriceInput.fill("480");

    // 47. Click Save Override
    const saveOverrideBtn = page.locator('[data-testid="btn-save-override"]');
    await saveOverrideBtn.click();

    // 48. Wait 3 seconds
    await page.waitForTimeout(3000);
  });
});
