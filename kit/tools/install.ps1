<#
  Reachy Mini student kit - installer for Windows 10/11 (no admin rights needed).
  Started by 1-INSTALL.cmd. Safe to run again (repairs / updates the setup).

  Steps: uv -> Python 3.12 -> virtual environment -> pinned packages ->
         Jupyter kernel -> robot motion datasets -> VS Code + extensions ->
         VS Code workspace -> shortcuts -> environment check

  Options:  -NoVSCode      do not install VS Code / extensions
            -NoShortcuts   do not create Start menu / desktop shortcuts
            -NoPrompt      do not ask to start the simulator at the end
#>
param(
    [switch]$NoVSCode,
    [switch]$NoShortcuts,
    [switch]$NoPrompt
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "common.ps1")

$LogDir = Join-Path $KitDir "logs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Start-Transcript -Path (Join-Path $LogDir "install.log") -Force | Out-Null
trap {
    Write-Host ""
    Write-Host "INSTALL FAILED: $_" -ForegroundColor Red
    Write-Host "The full log is in logs\install.log. Re-running 1-INSTALL.cmd often fixes network hiccups." -ForegroundColor Yellow
    Stop-Transcript | Out-Null
    if (-not $NoPrompt) { Wait-Enter }
    exit 1
}

function Step([string]$msg) { Write-Host ""; Write-Host "==> $msg" -ForegroundColor Cyan }
function Info([string]$msg) { Write-Host "    $msg" -ForegroundColor DarkGray }
function Check([string]$what) { if ($LASTEXITCODE -ne 0) { throw "$what failed (exit code $LASTEXITCODE)" } }

$kitVersion = (Get-Content (Join-Path $PSScriptRoot "kit-version.txt") -Raw).Trim()
Write-Host "Reachy Mini student kit $kitVersion" -ForegroundColor Green
Write-Host "Kit folder: $KitDir"

# 0. Files from a downloaded ZIP carry a 'downloaded from the internet' mark ---
Get-ChildItem -Path $KitDir -Recurse -File | Unblock-File -ErrorAction SilentlyContinue

# 1. uv ----------------------------------------------------------------------
Step "1/9  uv (Python installer by Astral)"
$uvBin = Join-Path $env:USERPROFILE ".local\bin"
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    if (-not (Test-Path (Join-Path $uvBin "uv.exe"))) {
        Info "installing uv from astral.sh ..."
        powershell -NoProfile -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
        Check "uv install"
    }
    $env:Path = "$uvBin;$env:Path"
}
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) { throw "uv not found after installing it. Close this window and run 1-INSTALL.cmd again." }
uv --version

# 2. Python ------------------------------------------------------------------
Step "2/9  Python 3.12"
$arch = $env:PROCESSOR_ARCHITECTURE
if ($env:PROCESSOR_ARCHITEW6432) { $arch = $env:PROCESSOR_ARCHITEW6432 }
$pyRequest = "3.12"
if ($arch -eq "ARM64") {
    # MuJoCo, GStreamer and the robot's motor/kinematics libraries ship no Windows-ARM64
    # builds, so use x64 Python, which Windows runs under emulation.
    $pyRequest = "cpython-3.12-windows-x86_64"
    Info "ARM64 laptop detected: using x64 Python (runs under Windows emulation)."
}
uv python install $pyRequest
Check "uv python install"

# 3. Virtual environment -----------------------------------------------------
Step "3/9  Virtual environment"
$venv = Get-KitVenv
if (-not $venv) {
    $venv = Join-Path $env:LOCALAPPDATA "ReachyMiniKit\venv"
    if ($venv -match '[^\x00-\x7F]') {
        # Precaution: keep native libraries (MuJoCo, GStreamer) away from non-ASCII paths
        # such as user names with umlauts.
        $venv = "C:\ReachyMiniKit\venv"
        try { New-Item -ItemType Directory -Force -Path "C:\ReachyMiniKit" | Out-Null }
        catch { $venv = Join-Path $env:PUBLIC "ReachyMiniKit\venv" }
        Info "your user folder contains special characters, using $venv"
    }
}
$Py = Join-Path $venv "Scripts\python.exe"
if (Test-Path $Py) {
    Info "reusing $venv"
} else {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $venv) | Out-Null
    uv venv $venv --python $pyRequest
    Check "uv venv"
}
[IO.File]::WriteAllText($VenvPathFile, $venv, (New-Object System.Text.ASCIIEncoding))

# 4. Packages ----------------------------------------------------------------
Step "4/9  Reachy Mini SDK, MuJoCo simulator and tools (first time: ~1 GB download)"
uv pip install --python $Py -r (Join-Path $PSScriptRoot "requirements.lock.txt")
Check "package install"

# 5. Jupyter kernel ----------------------------------------------------------
Step "5/9  Jupyter kernel 'Python (Reachy Mini)'"
& $Py -m ipykernel install --user --name $KernelName --display-name "Python (Reachy Mini)" | Out-Host
Check "kernel registration"

# 6. Recorded robot moves (so emotions/dances also work offline) -------------
Step "6/9  Downloading recorded emotions and dances"
$env:HF_HUB_DISABLE_SYMLINKS_WARNING = "1"
$env:HF_HUB_DISABLE_PROGRESS_BARS = "1"
& $Py -c "from huggingface_hub import snapshot_download as d; [d(r, repo_type='dataset') for r in ('pollen-robotics/reachy-mini-emotions-library', 'pollen-robotics/reachy-mini-dances-library')]; print('    ok')" | Out-Host
if ($LASTEXITCODE -ne 0) { Write-Host "    skipped (no internet?) - they will download on first use" -ForegroundColor Yellow }

# 7. VS Code -----------------------------------------------------------------
Step "7/9  VS Code"
$code = Find-VSCode
if (-not $code -and -not $NoVSCode) {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Info "installing VS Code with winget (accepts the Microsoft license for you) ..."
        winget install --id Microsoft.VisualStudioCode -e --scope user --silent --accept-source-agreements --accept-package-agreements
        if (-not (Find-VSCode)) {
            winget install --id Microsoft.VisualStudioCode -e --silent --accept-source-agreements --accept-package-agreements
        }
        $code = Find-VSCode
    }
    if (-not $code) {
        Write-Host "    Could not install VS Code automatically. Get it from https://code.visualstudio.com and run 1-INSTALL.cmd again." -ForegroundColor Yellow
    }
}
if ($code -and -not $NoVSCode) {
    Info "VS Code: $code"
    Info "installing extensions: Python, Jupyter"
    & $code --install-extension ms-python.python --install-extension ms-toolsai.jupyter | Out-Host
    if ($LASTEXITCODE -ne 0) { Write-Host "    extension install failed, VS Code will offer them when you open the workspace" -ForegroundColor Yellow }
} elseif ($NoVSCode) {
    Info "skipped (-NoVSCode)"
}

# Let PowerShell terminals (e.g. in VS Code) activate the venv. This is the same
# step the official Reachy Mini guide asks for. Only changed if scripts are blocked.
$policy = "Restricted"
$list = Get-ExecutionPolicy -List
foreach ($scope in "MachinePolicy", "UserPolicy", "CurrentUser", "LocalMachine") {
    $p = "$(($list | Where-Object Scope -eq $scope).ExecutionPolicy)"
    if ($p -and $p -ne "Undefined") { $policy = $p; break }
}
if ($policy -eq "Restricted") {
    try { Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force -ErrorAction Stop } catch { }
    if ("$(Get-ExecutionPolicy -Scope CurrentUser)" -eq "RemoteSigned") { Info "PowerShell execution policy for your user set to RemoteSigned" }
}

# 8. VS Code workspace -------------------------------------------------------
Step "8/9  VS Code workspace (reachy-mini.code-workspace)"
$template = Get-Content (Join-Path $PSScriptRoot "workspace.template.json") -Raw
$workspaceFile = Join-Path $KitDir "reachy-mini.code-workspace"
$json = $template.Replace("__PYTHON__", $Py.Replace("\", "\\"))
[IO.File]::WriteAllText($workspaceFile, $json, (New-Object System.Text.UTF8Encoding $false))
Info "interpreter: $Py"

# 9. Shortcuts ---------------------------------------------------------------
Step "9/9  Shortcuts"
if ($NoShortcuts) {
    Info "skipped (-NoShortcuts)"
} else {
    $shell = New-Object -ComObject WScript.Shell
    function New-Link([string]$path, [string]$target, [string]$arguments, [string]$icon, [string]$description) {
        $lnk = $shell.CreateShortcut($path)
        $lnk.TargetPath = $target
        $lnk.Arguments = $arguments
        $lnk.WorkingDirectory = $KitDir
        if ($icon) { $lnk.IconLocation = $icon }
        $lnk.Description = $description
        $lnk.Save()
    }
    $startMenu = Join-Path ([Environment]::GetFolderPath("Programs")) $ShortcutFolderName
    $desktop = [Environment]::GetFolderPath("Desktop")
    New-Item -ItemType Directory -Force -Path $startMenu | Out-Null

    $simCmd = Join-Path $KitDir "2-START-SIMULATOR.cmd"
    $simIcon = "$Py,0"
    New-Link (Join-Path $startMenu "Reachy Mini Simulator.lnk") $simCmd "" $simIcon "Start the MuJoCo simulation of Reachy Mini"
    New-Link (Join-Path $startMenu "Reachy Mini Simulator (empty scene).lnk") $simCmd "empty" $simIcon "Simulation without the table"
    New-Link (Join-Path $startMenu "Reachy Mini Kit folder.lnk") (Join-Path $env:WINDIR "explorer.exe") "`"$KitDir`"" "" "Open the kit folder"
    New-Link (Join-Path $startMenu "Uninstall Reachy Mini Kit.lnk") (Join-Path $KitDir "tools\UNINSTALL.cmd") "" "" "Remove the kit's Python environment and shortcuts"
    New-Link (Join-Path $desktop "Reachy Mini Simulator.lnk") $simCmd "" $simIcon "Start the MuJoCo simulation of Reachy Mini"
    if ($code) {
        $codeExe = Get-VSCodeExe $code
        if ($codeExe) {
            New-Link (Join-Path $startMenu "Reachy Mini Code (VS Code).lnk") $codeExe "`"$workspaceFile`"" "" "Open the kit in VS Code"
            New-Link (Join-Path $desktop "Reachy Mini Code (VS Code).lnk") $codeExe "`"$workspaceFile`"" "" "Open the kit in VS Code"
        }
    }
    Info "Start menu folder '$ShortcutFolderName' and desktop icons created"
}

# Check ----------------------------------------------------------------------
Step "Checking the installation"
& $Py (Join-Path $PSScriptRoot "check_env.py") | Out-Host
$ok = ($LASTEXITCODE -eq 0)
Write-Host ""
if ($ok) {
    Write-Host "Installation complete!" -ForegroundColor Green
} else {
    Write-Host "Installed, but some checks failed (see above and logs\install.log)." -ForegroundColor Yellow
}
Write-Host "Next: double-click 2-START-SIMULATOR.cmd (or the 'Reachy Mini Simulator' desktop icon),"
Write-Host "      then 3-OPEN-VSCODE.cmd and run my-code\my_first_program.py with Ctrl+Shift+B."
Stop-Transcript | Out-Null

if (-not $NoPrompt) {
    Write-Host ""
    $answer = Read-Host "Start the simulator and open VS Code now? [Y/n]"
    if ($answer -notmatch '^(n|no)$') {
        Start-Process -FilePath (Join-Path $KitDir "2-START-SIMULATOR.cmd") -WorkingDirectory $KitDir
        if ($code) { & $code $workspaceFile }
    }
}
