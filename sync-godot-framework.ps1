# Sync .cursor and zfoo from godot-fun/godot-framework into this project.
# Usage (from project root):
#   .\sync-godot-framework.ps1

param(
	[string]$RepoUrl = "https://github.com/godot-fun/godot-framework.git"
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Resolve-Path $PSScriptRoot
$TempRoot = Join-Path $env:TEMP ("godot-framework-sync-{0}" -f [guid]::NewGuid().ToString("N"))
$CloneDir = $TempRoot

New-Item -ItemType Directory -Path $TempRoot -Force | Out-Null

function Remove-TempRoot {
	if (Test-Path $TempRoot) {
		Write-Host "Cleaning up temporary directory: $TempRoot"
		Remove-Item -Path $TempRoot -Recurse -Force
	}
}

function Copy-DirReplace {
	param(
		[string]$Source,
		[string]$Destination
	)

	if (-not (Test-Path $Source)) {
		throw "Directory not found: $Source"
	}

	Write-Host "Replacing $Destination"
	if (Test-Path $Destination) {
		Remove-Item -Path $Destination -Recurse -Force
	}
	Copy-Item -Path $Source -Destination $Destination -Recurse -Force
}

function Copy-DirOverlay {
	param(
		[string]$Source,
		[string]$Destination
	)

	if (-not (Test-Path $Source)) {
		throw "Directory not found: $Source"
	}

	Write-Host "Overlaying $Destination"
	Copy-Item -Path $Source -Destination $Destination -Recurse -Force
}

function Copy-FrameworkDirs {
	param(
		[string]$SourceRoot
	)

	Copy-DirOverlay -Source (Join-Path $SourceRoot ".cursor") -Destination (Join-Path $ProjectRoot ".cursor")
	Copy-DirReplace -Source (Join-Path $SourceRoot "zfoo") -Destination (Join-Path $ProjectRoot "zfoo")
}

function Copy-ReadmeToZfoo {
	param(
		[string]$SourceRoot
	)

	$src = Join-Path $SourceRoot "README.md"
	$dst = Join-Path $ProjectRoot "zfoo\README.md"

	if (-not (Test-Path $src)) {
		throw "README.md not found in source repo"
	}

	Write-Host "Copying README.md -> $dst"
	Copy-Item -Path $src -Destination $dst -Force
}

try {
	Write-Host "Cloning $RepoUrl ..."
	git clone --depth 1 $RepoUrl $CloneDir
	if ($LASTEXITCODE -ne 0) {
		throw "git clone failed with exit code $LASTEXITCODE"
	}

	Copy-FrameworkDirs -SourceRoot $CloneDir
	Copy-ReadmeToZfoo -SourceRoot $CloneDir

	Write-Host "Sync completed."
} catch {
	Write-Error $_
	exit 1
} finally {
	Remove-TempRoot
}
