<#
  Remove what the Reachy Mini kit installed: its Python environment, Jupyter kernel,
  VS Code workspace file and shortcuts. Your code in this folder is NOT deleted.
  Shared tools (uv, the uv-managed Python, VS Code) stay installed, since other
  projects may use them.
#>
. (Join-Path $PSScriptRoot "common.ps1")

Write-Host "This removes the Reachy Mini kit's Python environment (~1.5 GB), Jupyter kernel and shortcuts."
Write-Host "Your files in $KitDir are kept."
$answer = Read-Host "Type YES to continue"
if ($answer -ne "YES") { Write-Host "Cancelled."; Wait-Enter; exit 0 }

$venv = Get-KitVenv
if ($venv -and (Test-Path $venv)) {
    Write-Host "Removing $venv"
    Remove-Item -Recurse -Force $venv
    $parent = Split-Path -Parent $venv
    if ((Test-Path $parent) -and -not (Get-ChildItem $parent -Force)) { Remove-Item $parent -Force }
}
$kernel = Join-Path $env:APPDATA "jupyter\kernels\$KernelName"
if (Test-Path $kernel) { Write-Host "Removing Jupyter kernel"; Remove-Item -Recurse -Force $kernel }

$startMenu = Join-Path ([Environment]::GetFolderPath("Programs")) $ShortcutFolderName
if (Test-Path $startMenu) { Write-Host "Removing Start menu folder"; Remove-Item -Recurse -Force $startMenu }
$desktop = [Environment]::GetFolderPath("Desktop")
foreach ($name in "Reachy Mini Simulator.lnk", "Reachy Mini Code (VS Code).lnk") {
    $p = Join-Path $desktop $name
    if (Test-Path $p) { Remove-Item -Force $p }
}
foreach ($f in (Join-Path $KitDir "reachy-mini.code-workspace"), $VenvPathFile) {
    if (Test-Path $f) { Remove-Item -Force $f }
}
Write-Host ""
Write-Host "Done. You can delete the kit folder yourself if you don't need your code anymore." -ForegroundColor Green
Wait-Enter
