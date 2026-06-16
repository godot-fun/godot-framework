# 从 godot-fun/godot-framework 同步 .cursor 与 zfoo 到本项目。
# 用法（在项目根目录）:
#   powershell -ExecutionPolicy Bypass -File sync-godot-framework.ps1
#
# 可选参数:
#   -UseZip    下载 ZIP 并解压（不依赖 git）
#   -Branch    分支名，默认 main

param(
	[string]$RepoUrl = "https://github.com/godot-fun/godot-framework.git",
	[string]$Branch = "main",
	[switch]$UseZip
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Resolve-Path $PSScriptRoot
$TempRoot = Join-Path $env:TEMP ("godot-framework-sync-{0}" -f [guid]::NewGuid().ToString("N"))
$CloneDir = $TempRoot
$ExtractedRoot = $null

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
	if ($UseZip) {
		$zipUrl = "https://github.com/godot-fun/godot-framework/archive/refs/heads/$Branch.zip"
		$zipFile = Join-Path $TempRoot "godot-framework.zip"

		Write-Host "Downloading $zipUrl ..."
		Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile

		Write-Host "Extracting archive ..."
		Expand-Archive -Path $zipFile -DestinationPath $TempRoot -Force

		$ExtractedRoot = Get-ChildItem -Path $TempRoot -Directory |
			Where-Object { $_.Name -like "godot-framework-*" } |
			Select-Object -First 1

		if (-not $ExtractedRoot) {
			throw "Failed to locate extracted repository directory."
		}

		Copy-FrameworkDirs -SourceRoot $ExtractedRoot.FullName
	} else {
		Write-Host "Cloning $RepoUrl (branch: $Branch) ..."
		git clone --depth 1 --branch $Branch $RepoUrl $CloneDir
		if ($LASTEXITCODE -ne 0) {
			throw "git clone failed with exit code $LASTEXITCODE"
		}

		Copy-FrameworkDirs -SourceRoot $CloneDir
	}

	Write-Host "Sync completed."
} catch {
	Write-Error $_
	exit 1
} finally {
	Remove-TempRoot
}
