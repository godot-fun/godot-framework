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

function Copy-FrameworkDirs {
	param(
		[string]$SourceRoot
	)

	foreach ($dir in @(".cursor", "zfoo")) {
		$src = Join-Path $SourceRoot $dir
		$dst = Join-Path $ProjectRoot $dir

		if (-not (Test-Path $src)) {
			throw "Directory not found in source repo: $dir"
		}

		Write-Host "Copying $dir -> $dst"
		if (Test-Path $dst) {
			Remove-Item -Path $dst -Recurse -Force
		}
		Copy-Item -Path $src -Destination $dst -Recurse -Force
	}
}

try {
	Write-Host "Cloning $RepoUrl ..."
	git clone --depth 1 $RepoUrl $CloneDir
	if ($LASTEXITCODE -ne 0) {
		throw "git clone failed with exit code $LASTEXITCODE"
	}

	Copy-FrameworkDirs -SourceRoot $CloneDir

	Write-Host "Sync completed."
} catch {
	Write-Error $_
	exit 1
} finally {
	Remove-TempRoot
}
