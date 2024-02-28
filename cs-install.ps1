param (
    [Parameter(Mandatory=$true)]
    [string]$ClientId,
    [Parameter(Mandatory=$true)]
    [string]$ClientSecret
)

# Install Nuget and PSFalcon
Install-PackageProvider -Name NuGet -Force
Install-Module -Name psfalcon -Force
Import-Module -Name psfalcon

# Bug fix code: https://github.com/CrowdStrike/psfalcon/issues/382#issuecomment-1961927325
$ModulePath = (Show-FalconModule).ModulePath
(Invoke-WebRequest -Uri https://raw.githubusercontent.com/CrowdStrike/psfalcon/e60951774c23443ce7d3c7788c823d268c2a7fc1/private/Private.ps1 -UseBasicParsing).Content > (Join-Path (Join-Path $ModulePath private) Private.ps1)
(Invoke-WebRequest -Uri https://raw.githubusercontent.com/CrowdStrike/psfalcon/e60951774c23443ce7d3c7788c823d268c2a7fc1/class/Class.ps1 -UseBasicParsing).Content > (Join-Path (Join-Path $ModulePath class) Class.ps1)

# Get Token
Request-FalconToken -ClientId $ClientId -ClientSecret $ClientSecret

# Test Token
if ((Test-FalconToken).Token) {
    $filepath = $PSScriptRoot + '\WindowsSensor.exe'
    $cid = Get-FalconCcid

    # Download Sensor
    Get-FalconInstaller -Detailed -Limit 1 -Filter "platform:'windows'" | Receive-FalconInstaller -Path $filepath
    
    # Install Sensor
    if (Test-Path $filepath) {
        Start-Process -FilePath $filepath -ArgumentList "/silent", "/NORESTART", "CID=$cid" -Wait
    }
}