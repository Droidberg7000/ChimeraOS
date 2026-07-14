<#
.SYNOPSIS
    Mirrors this repo onto the "ChimeraOS" SanDisk 500GB external drive on Windows.

.DESCRIPTION
    Auto-detects a removable/external drive whose volume label is "ChimeraOS"
    and mirrors this repo's working tree into <drive>:\ChimeraOS-final-build\,
    excluding .git, __pycache__, and node_modules. Uses robocopy in mirror
    mode (/MIR), so re-running after plugging the drive back in keeps it in
    sync incrementally rather than re-copying everything.

.PARAMETER DriveLetter
    Optional explicit drive letter (e.g. "E:") if auto-detection doesn't find
    the volume by label (some enclosures/reformats can lose the label).

.EXAMPLE
    .\scripts\Sync-ToChimeraOSDrive.ps1
    .\scripts\Sync-ToChimeraOSDrive.ps1 -DriveLetter E:
#>

param(
    [string]$DriveLetter
)

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$VolumeLabel = "ChimeraOS"
$DestSubdir = "ChimeraOS-final-build"

if (-not $DriveLetter) {
    $vol = Get-Volume | Where-Object { $_.FileSystemLabel -eq $VolumeLabel } | Select-Object -First 1
    if (-not $vol) {
        Write-Error "Could not find a mounted volume labeled '$VolumeLabel'. Plug in the drive, or re-run with -DriveLetter E: (whatever it actually mounted as)."
        exit 1
    }
    $DriveLetter = "$($vol.DriveLetter):"
}

if (-not (Test-Path $DriveLetter)) {
    Write-Error "Drive '$DriveLetter' does not exist or isn't mounted."
    exit 1
}

$Dest = Join-Path $DriveLetter $DestSubdir
New-Item -ItemType Directory -Force -Path $Dest | Out-Null

Write-Host "Syncing $RepoRoot -> $Dest"

# /MIR mirrors source to dest (adds+updates+deletes), /XD excludes dirs by name.
robocopy $RepoRoot $Dest /MIR /XD ".git" "__pycache__" "node_modules" /R:2 /W:2 /NFL /NDL

# robocopy exit codes 0-7 are all "success" (8+ means real errors).
if ($LASTEXITCODE -ge 8) {
    Write-Error "robocopy reported errors (exit code $LASTEXITCODE)."
    exit $LASTEXITCODE
}

$Stamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
Set-Content -Path (Join-Path $Dest ".last_synced_utc") -Value $Stamp

Write-Host "Done. Last synced (UTC): $Stamp"
