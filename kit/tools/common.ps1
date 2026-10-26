# common.ps1 - shared helpers for the Reachy Mini kit scripts (dot-sourced).

$KitDir = Split-Path -Parent $PSScriptRoot
$VenvPathFile = Join-Path $PSScriptRoot "venv-path.txt"
$KernelName = "reachy-mini-kit"
$ShortcutFolderName = "Reachy Mini Kit"

function Get-KitVenv {
    # Where install.ps1 put the virtual environment (written at install time).
    if (Test-Path $VenvPathFile) {
        $p = (Get-Content $VenvPathFile -Raw).Trim()
        if ($p) { return $p }
    }
    return $null
}

function Find-VSCode {
    # Returns the path of code.cmd (VS Code command line), or $null.
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Microsoft VS Code\bin\code.cmd"),
        (Join-Path $env:ProgramFiles "Microsoft VS Code\bin\code.cmd")
    )
    foreach ($c in $candidates) { if (Test-Path $c) { return $c } }
    $cmd = Get-Command code.cmd -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}

function Get-VSCodeExe([string]$codeCmd) {
    # ...\Microsoft VS Code\bin\code.cmd -> ...\Microsoft VS Code\Code.exe
    $exe = Join-Path (Split-Path -Parent (Split-Path -Parent $codeCmd)) "Code.exe"
    if (Test-Path $exe) { return $exe }
    return $null
}

function Wait-Enter([string]$msg = "Press Enter to close this window") {
    Write-Host ""
    [void](Read-Host $msg)
}
