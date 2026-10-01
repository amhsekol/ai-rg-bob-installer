$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
. (Join-Path $root 'Setup-Bob.ps1')
$script:passed=0
function Assert($ok,$name) { if (-not $ok) { throw "FAILED: $name" }; $script:passed++; Write-Host "PASS $name" }
function Reject($action,$name) { $failed=$false; try { & $action } catch { $failed=$true }; Assert $failed $name }
$sandbox=Join-Path ([IO.Path]::GetTempPath()) ('bob-setup-test-'+[guid]::NewGuid().ToString('N'))
$saved=@{LOCALAPPDATA=$env:LOCALAPPDATA;USERPROFILE=$env:USERPROFILE;OS=$env:OS}
$script:running=$false
$script:packageInstalls=0; $script:claudeInstalls=0; $script:logins=0
$script:found=$true; $script:loggedIn=$true; $script:loginFails=$false; $script:packageFails=$false; $script:claudeFails=$false
try {
    Assert ((Get-FileHash (Join-Path $root 'Install-Bob.ps1')).Hash -eq $script:BobSetupInstallerHash) 'setup pins exact verified installer bytes'
    $env:LOCALAPPDATA=Join-Path $sandbox 'Local'; $env:USERPROFILE=Join-Path $sandbox 'User'; $env:OS='Windows_NT'
    New-Item -ItemType Directory -Force $env:LOCALAPPDATA,$env:USERPROFILE | Out-Null
    function Get-Process { param($Name,$ErrorAction) if ($script:running) { [pscustomobject]@{Name='Revit'} } }
    $script:claude=Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\claude.exe'
    New-Item -ItemType Directory -Force (Split-Path $script:claude) | Out-Null
    Set-Content $script:claude 'inert exe marker - never executed'
    Assert ((Find-BobClaude) -eq $script:claude) 'WinGet native executable found without fresh shell'
    function Find-BobClaude { if ($script:found) { return $script:claude }; return $null }
    function Install-BobClaude { $script:claudeInstalls++; if ($script:claudeFails) { throw 'Simulated winget failure' }; $script:found=$true }
    function Confirm-BobClaudeExecutable { param($Path) Assert ($Path -eq $script:claude) 'setup uses discovered native executable' }
    $valid=[pscustomobject]@{loggedIn=$true;authMethod='claude.ai';apiProvider='firstParty';subscriptionType='team';apiKeySource=$null}
    Assert (Test-BobSubscription $valid) 'team subscription accepted'
    foreach ($plan in 'pro','max','enterprise') { $valid.subscriptionType=$plan; Assert (Test-BobSubscription $valid) "$plan subscription accepted" }
    $valid.subscriptionType='free'; Assert (-not (Test-BobSubscription $valid)) 'unsupported plan rejected'
    $valid.subscriptionType='team'; $valid.apiKeySource='environment'; Assert (-not (Test-BobSubscription $valid)) 'API billing rejected'
    Assert (-not (Test-BobSubscription $null)) 'missing login status rejected'
    function Get-BobClaudeStatus {
        param($Path)
        if ($script:loggedIn) { return [pscustomobject]@{loggedIn=$true;authMethod='claude.ai';apiProvider='firstParty';subscriptionType='team'} }
        return $null
    }
    function Start-BobClaudeLogin { param($Path) $script:logins++; if ($script:loginFails) { throw 'Simulated login cancellation' }; $script:loggedIn=$true }
    # Exercise the real bootstrap download/check/cleanup with an inert fixture.
    $fixture=Join-Path $sandbox 'bootstrap.ps1'; Set-Content $fixture '# inert bootstrap'
    $realHash=$script:BobSetupInstallerHash
    $script:BobSetupInstallerHash=(Get-FileHash $fixture).Hash
    $script:lastDownload=''
    function Invoke-WebRequest {
        param([switch]$UseBasicParsing,$Uri,$OutFile,$TimeoutSec)
        Assert ($Uri -eq 'https://raw.githubusercontent.com/amhsekol/ai-rg-bob-installer/main/Install-Bob.ps1') 'bootstrap restricted to public repository'
        $script:lastDownload=$OutFile; Copy-Item $fixture $OutFile
    }
    function Start-BobSetupInstallerProcess { param($Path) $script:packageInstalls++; Assert (Test-Path $Path) 'verified bootstrap passed to child' }
    Install-BobSetupPackage
    Assert (-not (Test-Path (Split-Path $script:lastDownload))) 'bootstrap download removed after install'
    $script:BobSetupInstallerHash='0'*64
    Reject { Install-BobSetupPackage } 'substituted bootstrap blocked'
    Assert ($script:packageInstalls -eq 1) 'bad bootstrap cannot execute'
    $script:BobSetupInstallerHash=$realHash
    function Install-BobSetupPackage { $script:packageInstalls++; if ($script:packageFails) { throw 'Simulated plugin installer failure' } }
    $script:packageInstalls=0
    Invoke-BobSetup
    Assert ($script:claudeInstalls -eq 0 -and $script:logins -eq 0) 'existing eligible login reused without reinstall or sign-out'
    $settings=Join-Path $env:LOCALAPPDATA 'RGConstruction\RevitAI\settings.json'
    $config=Get-Content $settings -Raw | ConvertFrom-Json
    Assert ($config.ClaudePath -eq $script:claude) 'Claude path configured automatically'
    Assert (-not $config.CloudConsent -and -not $config.AllowAdvancedRevitCode -and -not $config.SaveLocalHistory) 'first install never grants data code or history consent'
    $config.Model='custom-model'; $config.CloudConsent=$true; $config.SaveLocalHistory=$true
    $config | Add-Member -NotePropertyName FutureSetting -NotePropertyValue 'preserve'
    $config.ClaudePath='old.exe'
    $config | ConvertTo-Json | Set-Content $settings
    Save-BobClaudePath $script:claude
    $config=Get-Content $settings -Raw | ConvertFrom-Json
    Assert ($config.Model -eq 'custom-model' -and $config.CloudConsent -and $config.SaveLocalHistory -and $config.FutureSetting -eq 'preserve') 'existing preferences and unknown fields preserved'
    Assert (@(Get-ChildItem (Join-Path (Split-Path $settings) 'Backups') -Filter 'settings-before-setup-*.json').Count -eq 1) 'changed settings backed up atomically'
    $script:found=$false; $script:loggedIn=$false
    Invoke-BobSetup
    Assert ($script:claudeInstalls -eq 1 -and $script:logins -eq 1) 'fresh setup installs Claude and requests official sign-in'
    $before=$script:packageInstalls
    $script:loggedIn=$false; $script:loginFails=$true
    Reject { Invoke-BobSetup } 'cancelled sign-in stops setup'
    Assert ($script:packageInstalls -eq $before) 'cancelled sign-in does not install Bob'
    $script:loginFails=$false; $script:loggedIn=$true; $script:running=$true
    Reject { Invoke-BobSetup } 'open Revit blocks all setup'
    Assert ($script:packageInstalls -eq $before) 'open Revit causes no plugin changes'
    $script:running=$false; $script:found=$false; $script:claudeFails=$true
    Reject { Invoke-BobSetup } 'Claude installer failure stops setup'
    Assert ($script:packageInstalls -eq $before) 'Claude install failure cannot report Bob installed'
    $script:found=$true; $script:claudeFails=$false
    $original=[IO.File]::ReadAllText($settings)
    Set-Content $settings '{broken'
    Reject { Invoke-BobSetup } 'invalid settings fail before installation'
    Assert ($script:packageInstalls -eq $before -and (Get-Content $settings -Raw).Contains('{broken')) 'invalid settings never overwritten'
    [IO.File]::WriteAllText($settings,$original)
    $script:packageFails=$true
    Reject { Invoke-BobSetup } 'plugin installer failure propagates'
    Assert ([IO.File]::ReadAllText($settings) -eq $original) 'plugin failure does not rewrite settings'
    Write-Host "$script:passed setup checks passed. Claude, winget and installation actions used inert fixtures."
} finally {
    $env:LOCALAPPDATA=$saved.LOCALAPPDATA; $env:USERPROFILE=$saved.USERPROFILE; $env:OS=$saved.OS
    if (Test-Path $sandbox) { Remove-Item $sandbox -Recurse -Force }
}
