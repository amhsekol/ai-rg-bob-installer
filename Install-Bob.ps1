# AI RG / Bob: public installer. No GitHub account, CLI, token or API key required.
[CmdletBinding()]
param([ValidateSet('All','2024','2025','2026')][string[]]$Versions = @('All'))
$ErrorActionPreference = 'Stop'
$script:BobVersion = '3.0.0'
$script:BobFile = 'RG-AI-Assistant-Revit2024-2025-2026-v3.0.0.zip'
$script:BobHash = '266a6aaadf1e39e4a0819d45c1e681adc163eb8da8227f3caf55ce07f0d31133'
$script:BobUrl = "https://github.com/amhsekol/ai-rg-bob-installer/releases/download/v$script:BobVersion/$script:BobFile"

function Assert-BobPackage {
    param([string]$Path, [string]$ExpectedHash)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw 'Installer download did not complete.' }
    if ((Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash -ne $ExpectedHash) {
        throw 'Installer checksum mismatch. Nothing installed. Do not use this download.'
    }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [IO.Compression.ZipFile]::OpenRead($Path)
    try {
        if ($archive.Entries.Count -gt 1000) { throw 'Unexpected archive size.' }
        $size = 0L
        foreach ($entry in $archive.Entries) {
            $name = $entry.FullName.Replace('\','/')
            $size += $entry.Length
            if ($size -gt 500MB -or $entry.Length -gt 100MB) { throw 'Archive exceeds extraction limits.' }
            if ($name.StartsWith('/') -or $name.Contains(':') -or ($name -split '/') -contains '..') {
                throw 'Unsafe archive entry. Nothing installed.'
            }
        }
        if (-not $archive.GetEntry('Install-Revit.ps1')) { throw 'Archive is missing its installer.' }
    } finally { $archive.Dispose() }
}

function Install-Bob {
    param([ValidateSet('All','2024','2025','2026')][string[]]$TargetVersions = @('All'))
    if ($env:OS -ne 'Windows_NT') { throw 'Bob requires Windows and a supported Revit installation.' }
    if (Get-Process -Name Revit -ErrorAction SilentlyContinue) {
        throw 'Save your work and close ALL Revit windows, then run this command again. Nothing installed.'
    }
    $work = Join-Path ([IO.Path]::GetTempPath()) ('Bob-Public-' + [guid]::NewGuid().ToString('N'))
    $oldProgress = $ProgressPreference
    $oldTls = [Net.ServicePointManager]::SecurityProtocol
    New-Item -ItemType Directory -Path $work | Out-Null
    try {
        $ProgressPreference = 'SilentlyContinue'
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Write-Host "Downloading Bob $script:BobVersion. No GitHub login required..." -ForegroundColor Cyan
        $zip = Join-Path $work $script:BobFile
        Invoke-WebRequest -UseBasicParsing -Uri $script:BobUrl -OutFile $zip -TimeoutSec 180
        Assert-BobPackage $zip $script:BobHash
        $package = Join-Path $work 'package'
        Expand-Archive -LiteralPath $zip -DestinationPath $package
        Write-Host 'Verified package. Installing matching Revit add-ins with backups...' -ForegroundColor Cyan
        # Inner installer checks all selected payload hashes before changing files.
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $package 'Install-Revit.ps1') -Versions ($TargetVersions -join ',')
        if ($LASTEXITCODE -ne 0) { throw 'Installation stopped. Review the installer message above before opening Revit.' }
    } finally {
        $ProgressPreference = $oldProgress
        [Net.ServicePointManager]::SecurityProtocol = $oldTls
        if (Test-Path -LiteralPath $work) {
            try { Remove-Item -LiteralPath $work -Recurse -Force }
            catch { Write-Warning "Could not remove temporary downloads at $work. Installation backups were not removed." }
        }
    }
    Write-Host ''
    Write-Host "Bob $script:BobVersion installed. Open Revit > AI RG > Chat with Bob." -ForegroundColor Green
    Write-Host 'Your existing Claude settings and installation backups are retained.'
    Write-Host 'New users: install official Claude Code and sign into your own eligible Claude account.'
    Write-Host 'Unsigned build. Test on a model copy before production use.'
}

if ($MyInvocation.InvocationName -ne '.') { Install-Bob -TargetVersions $Versions }
