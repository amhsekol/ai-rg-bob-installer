$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
. (Join-Path $root 'Install-Bob.ps1')
$script:passed = 0
function Assert($ok, $label) { if (-not $ok) { throw "FAILED: $label" }; $script:passed++; Write-Host "PASS $label" }
function Reject($action, $label) { $failed=$false; try { & $action } catch { $failed=$true }; Assert $failed $label }
$sandbox = Join-Path ([IO.Path]::GetTempPath()) ('bob-public-test-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $sandbox | Out-Null
$oldOs=$env:OS
$originalHash=$script:BobHash
$script:running=$false; $script:networkFailure=$false; $script:childFailure=$false
$script:downloads=0; $script:installs=0; $script:downloadPath=''; $script:lastVersions=''
try {
    $env:OS='Windows_NT'
    # Verify the actual distributable independently of mocked download fixtures.
    Assert-BobPackage (Join-Path $root "packages/$script:BobFile") $originalHash
    Assert $true 'actual release package hash and archive paths valid'
    $fixture=Join-Path $sandbox 'fixture'
    New-Item -ItemType Directory $fixture | Out-Null
    Set-Content (Join-Path $fixture 'Install-Revit.ps1') '# inert test fixture'
    $script:fixtureZip=Join-Path $sandbox 'fixture.zip'
    Compress-Archive -Path (Join-Path $fixture '*') -DestinationPath $script:fixtureZip
    $fixtureHash=(Get-FileHash $script:fixtureZip).Hash
    Assert-BobPackage $script:fixtureZip $fixtureHash
    Assert $true 'valid fixture accepted'
    Reject { Assert-BobPackage $script:fixtureZip ('0'*64) } 'corrupt or substituted package rejected'
    $unsafe=Join-Path $sandbox 'unsafe.zip'
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive=[IO.Compression.ZipFile]::Open($unsafe,[IO.Compression.ZipArchiveMode]::Create)
    try { $null=$archive.CreateEntry('../escape.ps1'); $null=$archive.CreateEntry('Install-Revit.ps1') } finally { $archive.Dispose() }
    Reject { Assert-BobPackage $unsafe (Get-FileHash $unsafe).Hash } 'archive traversal blocked'
    function Get-Process { param($Name,$ErrorAction) if ($script:running) { [pscustomobject]@{Name='Revit'} } }
    function Invoke-WebRequest {
        param([switch]$UseBasicParsing,$Uri,$OutFile,$TimeoutSec)
        $script:downloads++; $script:downloadPath=$OutFile
        Assert ($Uri -eq 'https://github.com/amhsekol/ai-rg-bob-installer/releases/download/v2.4.0-preview.1/RG-AI-Assistant-Revit2024-2025-2026-v2.4.0-preview.1.zip') 'download stays on exact public release URL'
        if ($script:networkFailure) { throw 'Simulated network failure' }
        Copy-Item $script:fixtureZip $OutFile
    }
    function powershell.exe {
        $script:installs++
        $path=$args[[array]::IndexOf($args,'-File')+1]
        $script:lastVersions=$args[[array]::IndexOf($args,'-Versions')+1]
        Assert (Test-Path $path) 'verified extracted installer passed to child'
        Assert ($args -contains '-NoProfile' -and $args -contains 'Bypass') 'execution policy is process-only'
        $global:LASTEXITCODE=if ($script:childFailure) {1} else {0}
    }
    $script:BobHash=$fixtureHash
    $tlsBefore=[Net.ServicePointManager]::SecurityProtocol
    Install-Bob -TargetVersions 2024,2026
    Assert ($script:installs -eq 1 -and $script:lastVersions -eq '2024,2026') 'selected years preserved'
    Assert (-not (Test-Path (Split-Path $script:downloadPath))) 'success cleans temporary downloads'
    Assert ([Net.ServicePointManager]::SecurityProtocol -eq $tlsBefore) 'TLS preference restored'
    $script:running=$true
    Reject { Install-Bob } 'open Revit blocks installation'
    Assert ($script:downloads -eq 1) 'open Revit blocks before network access'
    $script:running=$false; $script:networkFailure=$true
    Reject { Install-Bob } 'network failure stops installation'
    Assert ($script:installs -eq 1 -and -not (Test-Path (Split-Path $script:downloadPath))) 'failed download cleaned without installing'
    $script:networkFailure=$false; $script:BobHash='0'*64
    Reject { Install-Bob } 'downloaded bytes independently verified'
    Assert ($script:installs -eq 1 -and -not (Test-Path (Split-Path $script:downloadPath))) 'hash mismatch cannot install'
    $script:BobHash=$fixtureHash; $script:childFailure=$true
    Reject { Install-Bob } 'child installer failure reported'
    Assert (-not (Test-Path (Split-Path $script:downloadPath))) 'child failure cleanup'
    Reject { Install-Bob -TargetVersions 2023 } 'unsupported year rejected'
    $script:childFailure=$false
    $source=(Get-Content (Join-Path $root 'Install-Bob.ps1') -Raw).Replace($originalHash,$fixtureHash)
    # Exact public entry mechanism, with fixture download and child mocks only.
    $source | Invoke-Expression
    Assert ($script:lastVersions -eq 'All') 'download-and-execute entry point installs all supported years'
    Write-Host "$script:passed public installer checks passed."
} finally {
    $env:OS=$oldOs
    foreach ($name in @('Get-Process','Invoke-WebRequest','powershell.exe')) { Remove-Item "Function:\$name" -ErrorAction SilentlyContinue }
    Remove-Item -LiteralPath $sandbox -Recurse -Force
}
$global:LASTEXITCODE=0
