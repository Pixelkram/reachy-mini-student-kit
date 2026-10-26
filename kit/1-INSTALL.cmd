@echo off
rem Reachy Mini kit: one-time setup (about 5-10 minutes, no admin rights needed)
if not exist "%~dp0tools\install.ps1" (
  echo.
  echo  It looks like this runs from inside the ZIP file.
  echo  Please extract the ZIP first: right-click it, "Extract All...", then run 1-INSTALL.cmd from the extracted folder.
  echo.
  pause
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\install.ps1" %*
