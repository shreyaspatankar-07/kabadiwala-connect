@echo off
echo ===================================================
echo  Kabadiwala Connect - Android Demo Walkthrough
echo ===================================================
echo Starting Flutter Integration Test on emulator-5554...
echo Make sure screen recording / OBS is running!
cd /d "%~dp0\.."
flutter test integration_test/demo_walkthrough_test.dart -d emulator-5554 --verbose
echo Done.
