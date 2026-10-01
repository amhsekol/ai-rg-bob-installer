# One-command first-time setup. Browser sign-in and project-data permission remain personal.
$ErrorActionPreference = 'Stop'
$script:BobSetupInstallerHash = '0bb7efe31988a60d282dfca2ce80d70260c102865529e2e72f4608e6e56c5b7e'

function Assert-BobSetupClosed {
    if ($env:OS -ne 'Windows_NT') { throw 'Bob requires Windows and Revit 2024, 2025 or 2026.' }
    if (Get-Process Revit -ErrorAction SilentlyContinue) { throw 'Save your work and close ALL Revit windows, then run this command again.' }
}
function Find-BobClaude {
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\claude.exe'),
        (Join-Path $env:USERPROFILE '.local\bin\claude.exe')
    )
    $command = Get-Command claude.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) { $candidates += $command.Source }
    $config = Join-Path $env:LOCALAPPDATA 'RGConstruction\RevitAI\settings.json'
    if (Test-Path -LiteralPath $config) {
        try { $candidates += (Get-Content -LiteralPath $config -Raw | ConvertFrom-Json).ClaudePath } catch { }
    }
    foreach ($path in $candidates) {
        if ($path -and [IO.Path]::GetFileName($path) -ieq 'claude.exe' -and (Test-Path -LiteralPath $path -PathType Leaf)) {
            return [IO.Path]::GetFullPath($path)
        }
    }
    return $null
}
function Install-BobClaude {
    if (-not (Get-Command winget.exe -CommandType Application -ErrorAction SilentlyContinue)) {
        throw 'Windows App Installer / winget is missing. Ask IT to enable it, then rerun this same setup command. No settings were changed.'
    }
    Write-Host 'Installing official Claude Code for your Windows account...' -ForegroundColor Cyan
    & winget.exe install --id Anthropic.ClaudeCode --exact --source winget --scope user --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -ne 0) { throw 'Claude Code installation did not complete. Review the winget message; do not bypass company restrictions.' }
    # Refresh only this shell; preserve its existing entries and persistent PATH.
    $env:Path = $env:Path + ';' + [Environment]::GetEnvironmentVariable('Path','User') + ';' + [Environment]::GetEnvironmentVariable('Path','Machine')
}
function Confirm-BobClaudeExecutable {
    param([string]$Path)
    & $Path --version
    if ($LASTEXITCODE -ne 0) { throw 'Claude Code could not start. Contact IT if application execution is blocked.' }
}
function Get-BobClaudeStatus {
    param([string]$Path)
    # Only the official CLI reports login status. Never read/copy its credential files.
    try {
        $statusText = & $Path auth status 2>&1
        if ($LASTEXITCODE -ne 0) { return $null }
        return ($statusText -join "`n") | ConvertFrom-Json
    } catch { return $null }
}
function Test-BobSubscription {
    param($Status)
    return ($null -ne $Status -and $Status.loggedIn -eq $true -and $Status.authMethod -eq 'claude.ai' -and
        $Status.apiProvider -eq 'firstParty' -and -not $Status.apiKeySource -and
        @('pro','max','team','enterprise') -contains $Status.subscriptionType)
}
function Start-BobClaudeLogin {
    param([string]$Path)
    Write-Host 'Complete the official browser sign-in with YOUR Claude subscription account, not API/Console billing.' -ForegroundColor Cyan
    & $Path auth login
    if ($LASTEXITCODE -ne 0) { throw 'Claude sign-in did not complete. Rerun this setup when ready; no credentials were copied or saved by Bob setup.' }
}
function Read-BobSetupSettings {
    $path = Join-Path $env:LOCALAPPDATA 'RGConstruction\RevitAI\settings.json'
    if (-not (Test-Path -LiteralPath $path)) {
        return [pscustomobject]@{Model='sonnet'; CloudConsent=$false; AllowAdvancedRevitCode=$false; SaveLocalHistory=$false; AutomaticUpdateChecks=$true; ClaudePath=''}
    }
    try {
        $raw = Get-Content -LiteralPath $path -Raw
        if (-not $raw.TrimStart().StartsWith('{')) { throw 'Settings must be an object.' }
        $config = $raw | ConvertFrom-Json
    }
    catch { throw 'Existing Bob settings could not be read. Nothing was overwritten; restore or repair settings.json before setup.' }
    if ($null -eq $config -or $config -isnot [System.Management.Automation.PSCustomObject]) {
        throw 'Existing Bob settings are not a settings object. Nothing was overwritten.'
    }
    return $config
}
function Save-BobClaudePath {
    param([string]$ClaudePath)
    Assert-BobSetupClosed
    $config = Read-BobSetupSettings
    if ($config.ClaudePath -eq $ClaudePath) { return }
    $config | Add-Member -NotePropertyName ClaudePath -NotePropertyValue $ClaudePath -Force
    $folder = Join-Path $env:LOCALAPPDATA 'RGConstruction\RevitAI'
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
    $path = Join-Path $folder 'settings.json'
    $temporary = Join-Path $folder ('settings.' + [guid]::NewGuid().ToString('N') + '.tmp')
    try {
        [IO.File]::WriteAllText($temporary, ($config | ConvertTo-Json -Depth 50), (New-Object Text.UTF8Encoding($false)))
        if (Test-Path -LiteralPath $path) {
            $backups = Join-Path $folder 'Backups'
            New-Item -ItemType Directory -Path $backups -Force | Out-Null
            $backup = Join-Path $backups ('settings-before-setup-' + [guid]::NewGuid().ToString('N') + '.json')
            [IO.File]::Replace($temporary, $path, $backup)
        } else { [IO.File]::Move($temporary, $path) }
    } finally { if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force } }
}
function Start-BobSetupInstallerProcess {
    param([string]$Path)
    $shell = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    & $shell -NoProfile -ExecutionPolicy Bypass -File $Path -Versions All
    if ($LASTEXITCODE -ne 0) { throw 'Bob installation stopped. Review the installer output; setup has not reported success.' }
}
function Install-BobSetupPackage {
    $folder = Join-Path ([IO.Path]::GetTempPath()) ('bob-setup-' + [guid]::NewGuid().ToString('N'))
    $tls = [Net.ServicePointManager]::SecurityProtocol
    $progress = $ProgressPreference
    New-Item -ItemType Directory -Path $folder | Out-Null
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $ProgressPreference = 'SilentlyContinue'
        $path = Join-Path $folder 'Install-Bob.ps1'
        Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/amhsekol/ai-rg-bob-installer/main/Install-Bob.ps1' -OutFile $path -TimeoutSec 60
        if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $script:BobSetupInstallerHash) {
            throw 'Installer verification failed. Nothing installed by this step; retry later or contact support.'
        }
        Assert-BobSetupClosed
        Start-BobSetupInstallerProcess $path
    } finally {
        [Net.ServicePointManager]::SecurityProtocol = $tls
        $ProgressPreference = $progress
        if (Test-Path $folder) { Remove-Item -LiteralPath $folder -Recurse -Force }
    }
}
function Invoke-BobSetup {
    Assert-BobSetupClosed
    foreach ($name in @('ANTHROPIC_API_KEY','ANTHROPIC_AUTH_TOKEN','ANTHROPIC_BASE_URL','CLAUDE_CODE_OAUTH_TOKEN',
        'CLAUDE_CODE_USE_BEDROCK','CLAUDE_CODE_USE_VERTEX','CLAUDE_CODE_USE_FOUNDRY','ANTHROPIC_PROFILE',
        'ANTHROPIC_FEDERATION_RULE_ID','ANTHROPIC_IDENTITY_TOKEN_FILE','CLAUDE_CONFIG_DIR','CLAUDE_CODE_SIMPLE')) {
        if (-not [string]::IsNullOrEmpty([Environment]::GetEnvironmentVariable($name))) {
            throw "Subscription-only setup stopped: $name is configured. Review it with IT before setup. The setting and its value were not changed or displayed."
        }
    }
    $null = Read-BobSetupSettings # Validate before making installation changes.
    $claude = Find-BobClaude
    if (-not $claude) { Install-BobClaude; $claude = Find-BobClaude }
    if (-not $claude) { throw 'Claude Code was not found after installation. Reopen PowerShell and rerun this same command; ask IT if installation was blocked.' }
    Confirm-BobClaudeExecutable $claude
    if (-not (Test-BobSubscription (Get-BobClaudeStatus $claude))) {
        Start-BobClaudeLogin $claude
        if (-not (Test-BobSubscription (Get-BobClaudeStatus $claude))) {
            throw 'An eligible Claude subscription login was not confirmed. Use your own eligible Claude account; API billing is not accepted. Bob was not installed by this setup.'
        }
    }
    Install-BobSetupPackage
    Save-BobClaudePath $claude
    Write-Host '' 
    Write-Host 'Bob setup is complete. Claude Code is connected and its path is configured.' -ForegroundColor Green
    Write-Host 'Open a MODEL COPY in Revit > AI RG > Chat with Bob > AI Settings.'
    Write-Host 'Review and approve project-data sharing yourself, save settings, then check the subscription connection.'
    Write-Host 'New installs do NOT enable cloud sharing, advanced code or local chat saving automatically.'
    Write-Host 'Future updates: use Check for updates inside Bob. Follow company IT policies; the add-in is unsigned.'
}
if ($MyInvocation.InvocationName -ne '.') { Invoke-BobSetup }
