# get-reachy-kit.ps1 - one-line installer / updater for the Reachy Mini student kit.
#
# Students run (Start menu > type "Terminal" > paste > Enter):
#   powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/Pixelkram/reachy-mini-student-kit/main/get-reachy-kit.ps1 | iex"
#
# First run: downloads the kit ZIP, extracts it to %USERPROFILE%\reachy-mini-kit, runs the installer.
# Later runs: downloads the current ZIP, updates the kit's own files (tools\, launchers, README),
# adds new example files, keeps everything the student changed or created, re-runs the installer.
#
# The ZIP comes from the latest GitHub release of Pixelkram/reachy-mini-student-kit.
# To use another host, change $KitZipUrl (or set the REACHY_KIT_URL environment variable).

$KitZipUrl = "https://github.com/Pixelkram/reachy-mini-student-kit/releases/latest/download/reachy-mini-kit.zip"
if ($env:REACHY_KIT_URL) { $KitZipUrl = $env:REACHY_KIT_URL }
$KitDest = Join-Path $env:USERPROFILE "reachy-mini-kit"
if ($env:REACHY_KIT_DIR) { $KitDest = $env:REACHY_KIT_DIR }

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = "SilentlyContinue"   # makes Invoke-WebRequest much faster in PS 5.1

Write-Host "Reachy Mini student kit" -ForegroundColor Green
$installed = Test-Path (Join-Path $KitDest "tools\install.ps1")
if ($KitZipUrl -like "*YOUR-HOST*") {
    if (-not $installed) { throw "The download address is not set yet (instructor: edit KitZipUrl in get-reachy-kit.ps1)." }
    Write-Host "No download address set, re-running the installer of the existing kit."
} else {
    $tmpZip = Join-Path $env:TEMP ("reachy-mini-kit-" + [guid]::NewGuid().ToString("N") + ".zip")
    $tmpDir = Join-Path $env:TEMP ("reachy-mini-kit-" + [guid]::NewGuid().ToString("N"))
    Write-Host "Downloading $KitZipUrl ..."
    Invoke-WebRequest -Uri $KitZipUrl -OutFile $tmpZip -UseBasicParsing
    Expand-Archive -Path $tmpZip -DestinationPath $tmpDir -Force
    # The kit's files are either at the ZIP root or inside one top-level folder
    if (Test-Path (Join-Path $tmpDir "tools\install.ps1")) {
        $root = $tmpDir
    } else {
        $inner = Get-ChildItem $tmpDir -Directory | Where-Object { Test-Path (Join-Path $_.FullName "tools\install.ps1") } | Select-Object -First 1
        if (-not $inner) { throw "Unexpected ZIP layout: tools\install.ps1 not found." }
        $root = $inner.FullName
    }

    if (-not $installed) {
        try { Move-Item -Path $root -Destination $KitDest }
        catch { Copy-Item -Path $root -Destination $KitDest -Recurse }   # e.g. TEMP on another drive
        Write-Host "Extracted to $KitDest"
    } else {
        Write-Host "Updating the kit in $KitDest (your own files are kept) ..."
        Get-ChildItem $root -Recurse -File | ForEach-Object {
            $rel = $_.FullName.Substring($root.Length + 1)
            $target = Join-Path $KitDest $rel
            $kitOwned = ($rel -like "tools\*") -or ($rel -like "*.cmd") -or ($rel -eq "README.md")
            if ($kitOwned -or -not (Test-Path $target)) {
                New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
                Copy-Item -Path $_.FullName -Destination $target -Force
            }
        }
    }
    Remove-Item $tmpZip, $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
}
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $KitDest "tools\install.ps1")
