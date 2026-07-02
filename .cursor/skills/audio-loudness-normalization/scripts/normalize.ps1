#Requires -Version 5.1
<#
.SYNOPSIS
  Batch loudness-normalize audio files to a target LUFS using FFmpeg two-pass loudnorm.

.PARAMETER Input
  Path to a single audio file or a directory.

.PARAMETER TargetLUFS
  Target integrated loudness in LUFS (default: -14).

.PARAMETER TruePeak
  True peak limit in dBTP (default: -1.5).

.PARAMETER OutputDir
  Output directory. Default: "<input>/normalized" or "<parent>/normalized" for single files.

.PARAMETER Recurse
  Process subdirectories when Input is a folder.

.PARAMETER Overwrite
  Replace existing output files.

.PARAMETER DryRun
  List files that would be processed without writing output.
#>
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $Input,

    [double] $TargetLUFS = -14,
    [double] $TruePeak = -1.5,
    [string] $OutputDir = "",
    [switch] $Recurse,
    [switch] $Overwrite,
    [switch] $DryRun
)

$ErrorActionPreference = "Stop"
$AudioExtensions = @(".wav", ".mp3", ".ogg", ".flac", ".aac", ".m4a", ".wma")

function Test-FFmpeg {
    $cmd = Get-Command ffmpeg -ErrorAction SilentlyContinue
    if (-not $cmd) {
        Write-Error "FFmpeg not found on PATH. Install: winget install Gyan.FFmpeg"
    }
}

function Get-AudioFiles {
    param([string] $Path, [bool] $Recursive)

    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        $ext = [System.IO.Path]::GetExtension($Path).ToLowerInvariant()
        if ($AudioExtensions -contains $ext) {
            return @((Resolve-Path -LiteralPath $Path).Path)
        }
        Write-Error "Not a supported audio file: $Path"
    }

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        Write-Error "Input path not found: $Path"
    }

    $root = (Resolve-Path -LiteralPath $Path).Path
    $params = @{
        LiteralPath = $root
        File        = $true
        Include     = $AudioExtensions
    }
    if ($Recursive) { $params["Recurse"] = $true }
    return @(Get-ChildItem @params | ForEach-Object { $_.FullName })
}

function Get-LoudnormMeasurements {
    param(
        [string] $FilePath,
        [double] $I,
        [double] $TP
    )

    $stderr = & ffmpeg -hide_banner -nostats -i $FilePath `
        -af "loudnorm=I=${I}:TP=${TP}:LRA=11:print_format=json" `
        -f null - 2>&1 | Out-String

    if ($LASTEXITCODE -ne 0) {
        throw "FFmpeg analysis failed for: $FilePath`n$stderr"
    }

    $match = [regex]::Match($stderr, '\{[\s\S]*\}')
    if (-not $match.Success) {
        throw "Could not parse loudnorm JSON for: $FilePath"
    }

    return ($match.Value | ConvertFrom-Json)
}

function Normalize-AudioFile {
    param(
        [string] $FilePath,
        [string] $OutPath,
        [double] $I,
        [double] $TP,
        [object] $Measured
    )

    $outParent = Split-Path -Parent $OutPath
    if ($outParent -and -not (Test-Path -LiteralPath $outParent)) {
        New-Item -ItemType Directory -Path $outParent -Force | Out-Null
    }

    $filter = @(
        "loudnorm=I=${I}:TP=${TP}:LRA=11"
        "measured_I=$($Measured.input_i)"
        "measured_LRA=$($Measured.input_lra)"
        "measured_TP=$($Measured.input_tp)"
        "measured_thresh=$($Measured.input_thresh)"
        "offset=$($Measured.target_offset)"
        "linear=true"
    ) -join ":"

    & ffmpeg -hide_banner -nostats -y -i $FilePath -af $filter $OutPath 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "FFmpeg normalize failed for: $FilePath"
    }
}

Test-FFmpeg

$inputResolved = $Input
$files = Get-AudioFiles -Path $inputResolved -Recursive:$Recurse.IsPresent
if ($files.Count -eq 0) {
    Write-Host "No supported audio files found under: $Input"
    exit 0
}

$inputRoot = $Input
if ((Test-Path -LiteralPath $Input -PathType Leaf)) {
    $inputRoot = Split-Path -Parent (Resolve-Path -LiteralPath $Input).Path
    if (-not $inputRoot) { $inputRoot = (Get-Location).Path }
} else {
    $inputRoot = (Resolve-Path -LiteralPath $Input).Path
}

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path $inputRoot "normalized"
} else {
    $OutputDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDir)
}

Write-Host "Input:       $Input"
Write-Host "Files:       $($files.Count)"
Write-Host "Target LUFS: $TargetLUFS"
Write-Host "True Peak:   $TruePeak dBTP"
Write-Host "Output:      $OutputDir"
if ($DryRun) { Write-Host "Mode:        DRY RUN" }
Write-Host ""

$ok = 0
$skip = 0
$fail = 0

foreach ($file in $files) {
    $relative = if ($file.StartsWith($inputRoot, [StringComparison]::OrdinalIgnoreCase)) {
        $file.Substring($inputRoot.Length).TrimStart("\", "/")
    } else {
        Split-Path -Leaf $file
    }

    $outPath = Join-Path $OutputDir $relative

    if ((Test-Path -LiteralPath $outPath) -and -not $Overwrite -and -not $DryRun) {
        Write-Host "[skip] $relative"
        $skip++
        continue
    }

    if ($DryRun) {
        Write-Host "[plan] $relative -> $outPath"
        $ok++
        continue
    }

    try {
        Write-Host "[run]  $relative"
        $measured = Get-LoudnormMeasurements -FilePath $file -I $TargetLUFS -TP $TruePeak
        Normalize-AudioFile -FilePath $file -OutPath $outPath -I $TargetLUFS -TP $TruePeak -Measured $measured
        $ok++
    } catch {
        Write-Host "[fail] $relative"
        Write-Host $_.Exception.Message
        $fail++
    }
}

Write-Host ""
Write-Host "Done. processed=$ok skipped=$skip failed=$fail"
if ($fail -gt 0) { exit 1 }
