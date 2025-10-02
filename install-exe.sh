@echo off
SETLOCAL

echo ===============================
echo   Ultimate Chrome + AIO Setup
echo ===============================

:: ---------------------------
:: Step 1: Remove old Chrome (if exists)
:: ---------------------------
echo Removing old Google Chrome...
IF EXIST "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" (
    echo Found 32-bit Chrome, uninstalling...
    powershell -Command "Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like '*Chrome*'} | ForEach-Object { $_.Uninstall() }"
) ELSE IF EXIST "%ProgramFiles%\Google\Chrome\Application\chrome.exe" (
    echo Found 64-bit Chrome, uninstalling...
    powershell -Command "Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like '*Chrome*'} | ForEach-Object { $_.Uninstall() }"
) ELSE (
    echo No existing Chrome found.
)

:: ---------------------------
:: Step 2: Download latest Google Chrome
:: ---------------------------
echo Downloading Google Chrome...
powershell -Command "Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile '%TEMP%\chrome_installer.exe'"

:: ---------------------------
:: Step 3: Install Chrome silently
:: ---------------------------
echo Installing Google Chrome silently...
start /wait "" "%TEMP%\chrome_installer.exe" /silent /install
echo Chrome installation complete.

:: ---------------------------
:: Step 4: Create desktop shortcut
:: ---------------------------
echo Creating desktop shortcut for Chrome...
SET DESKTOP="%USERPROFILE%\Desktop\Google Chrome.lnk"
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut(%DESKTOP%);$s.TargetPath='%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe';$s.Save()"

:: ---------------------------
:: Step 5: Download AIO Runtimes
:: ---------------------------
echo Downloading AIO Runtimes...
powershell -Command "Invoke-WebRequest -Uri 'https://allinoneruntimes.org/files/aio-runtimes_v2.5.0.exe' -OutFile '%TEMP%\aio-runtimes_v2.5.0.exe'"

:: ---------------------------
:: Step 6: Run AIO Runtimes installer
:: ---------------------------
echo Running AIO Runtimes installer...
start "" "%TEMP%\aio-runtimes_v2.5.0.exe"

echo ===============================
echo Setup completed!
echo - Chrome shortcut added to Desktop.
echo - AIO Runtimes installer running.
echo ===============================
pause
ENDLOCAL
