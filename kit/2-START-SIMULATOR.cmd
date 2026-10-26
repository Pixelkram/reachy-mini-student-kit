@echo off
rem Starts the Reachy Mini simulator. Options: empty, -NoMedia
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\start-sim.ps1" %*
