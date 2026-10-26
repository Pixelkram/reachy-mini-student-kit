@echo off
rem Run a Python file with the kit's Python, e.g.:  run.cmd examples\01_hello_sim.py
setlocal
set "VENV="
if exist "%~dp0tools\venv-path.txt" set /p VENV=<"%~dp0tools\venv-path.txt"
if not defined VENV (
  echo The kit is not installed yet. Double-click 1-INSTALL.cmd first.
  exit /b 1
)
if not exist "%VENV%\Scripts\python.exe" (
  echo Python not found in %VENV%. Run 1-INSTALL.cmd again.
  exit /b 1
)
set HF_HUB_DISABLE_SYMLINKS_WARNING=1
"%VENV%\Scripts\python.exe" %*
exit /b %ERRORLEVEL%
