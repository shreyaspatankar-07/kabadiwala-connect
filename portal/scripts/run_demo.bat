@echo off
echo ===================================================
echo  Kabadiwala Connect - Recycler ^& Admin Portal Demo
echo ===================================================
echo Running Playwright headed demo script with video recording...
cd /d "%~dp0\.."
npx playwright test scripts/demo_walkthrough.spec.ts --headed --project=chromium
echo.
echo Demo recording complete!
echo Video saved to: portal\test-results\
pause
