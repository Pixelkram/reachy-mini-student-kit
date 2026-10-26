<#
  Start the Reachy Mini simulator (MuJoCo). Started by 2-START-SIMULATOR.cmd.

      2-START-SIMULATOR.cmd            robot on a table with objects (default)
      2-START-SIMULATOR.cmd empty      robot alone
      2-START-SIMULATOR.cmd -NoMedia   without simulated camera/audio (lighter)

  Your programs connect to http://localhost:8000, exactly like to a real robot.
  Stop: close this window (or press Ctrl+C).
#>
param(
    [Parameter(Position = 0)][ValidateSet("minimal", "empty")][string]$Scene = "minimal",
    [switch]$NoMedia,
    [switch]$Headless
)

. (Join-Path $PSScriptRoot "common.ps1")
$Host.UI.RawUI.WindowTitle = "Reachy Mini Simulator - close this window to stop"

$venv = Get-KitVenv
$daemon = if ($venv) { Join-Path $venv "Scripts\reachy-mini-daemon.exe" } else { $null }
if (-not $daemon -or -not (Test-Path $daemon)) {
    Write-Host "The kit is not installed yet. Double-click 1-INSTALL.cmd first." -ForegroundColor Red
    Wait-Enter; exit 1
}

# Only one simulator (or robot daemon) can use port 8000
$busy = Get-NetTCPConnection -LocalPort 8000 -State Listen -ErrorAction SilentlyContinue
if ($busy) {
    Write-Host "Port 8000 is already in use. Is the simulator already running in another window?" -ForegroundColor Yellow
    Write-Host "Close that window first (or the program using port 8000)." -ForegroundColor Yellow
    Wait-Enter; exit 1
}

$env:HF_HUB_DISABLE_SYMLINKS_WARNING = "1"
if ($env:NO_PROXY) { $env:NO_PROXY = "$env:NO_PROXY,localhost,127.0.0.1" } else { $env:NO_PROXY = "localhost,127.0.0.1" }

$logDir = Join-Path $KitDir "logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$logFile = Join-Path $logDir "sim.log"
Remove-Item $logFile -ErrorAction SilentlyContinue

$daemonArgs = @("--sim", "--scene", $Scene, "--log-file", $logFile)
if ($NoMedia) { $daemonArgs += "--no-media" }
if ($Headless) { $daemonArgs += "--headless" }

Write-Host "Starting the Reachy Mini simulator (scene: $Scene). The 3D window opens in a few seconds." -ForegroundColor Cyan
Write-Host "Mouse in the 3D window: left-drag rotate, right-drag move, scroll zoom." -ForegroundColor DarkGray
Write-Host "Keep this window open while you run programs. Close it to stop the simulator." -ForegroundColor DarkGray
Write-Host ""
& $daemon @daemonArgs
$code = $LASTEXITCODE
if ($code -ne 0) {
    Write-Host ""
    Write-Host "The simulator stopped (exit code $code). Details: logs\sim.log" -ForegroundColor Yellow
    Wait-Enter
}
