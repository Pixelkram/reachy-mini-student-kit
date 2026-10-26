# Open the kit in VS Code. Started by 3-OPEN-VSCODE.cmd.
. (Join-Path $PSScriptRoot "common.ps1")

$workspace = Join-Path $KitDir "reachy-mini.code-workspace"
if (-not (Test-Path $workspace)) {
    Write-Host "The kit is not installed yet. Double-click 1-INSTALL.cmd first." -ForegroundColor Red
    Wait-Enter; exit 1
}
$code = Find-VSCode
if (-not $code) {
    Write-Host "VS Code was not found. Install it from https://code.visualstudio.com and run 1-INSTALL.cmd again." -ForegroundColor Red
    Wait-Enter; exit 1
}
& $code $workspace
