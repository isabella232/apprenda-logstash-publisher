[CmdletBinding()]
param(
    $ApprendaSDKVersion = "7-0"
)
# Create temp paths
Write-Host "Creating temporary paths."
$tempPath = $env:TEMP + "\" + [System.Guid]::NewGuid() 
$powershellZipPath = "$tempPath\Powershell-JvB.zip"
$powershellPath = "$tempPath\Powershell-JvB"
$apprendaZipPath = "$tempPath\ApprendaSDK.zip"
$apprendaPath = "$tempPath\ApprendaSDK"
New-Item -ItemType Directory -Path $powershellPath -Force
New-Item -ItemType Directory -Path $apprendaPath -Force

# Download and install the Apprenda SDK if necessary
Write-Host "Looking for the Apprenda SDK"
if (Test-Path -Path "C:\Program Files (x86)\Apprenda\SDK") { 
    Write-Host "Apprenda SDK Found."
}
else {
    Write-Host "Installing Apprenda SDK $ApprendaSDKVersion"
    Invoke-WebRequest -Uri "https://docs.apprenda.com/sites/default/files/$($ApprendaSDKVersion)ApprendaSDK.zip" -OutFile $apprendaZipPath
    Unblock-File -Path $apprendaZipPath
    Expand-Archive -Path $apprendaZipPath -DestinationPath $apprendaPath
    Push-Location "$apprendaPath"
    msiexec.exe /i ApprendaSDK.msi /qf
    Pop-Location
}

# Download and install Powershell-JvB
Write-Host "Installing Powershell-JvB Module."
Invoke-WebRequest -Uri https://github.com/JasonvanBrackel/powershell-personal/archive/master.zip -OutFile $powershellZipPath
Unblock-File -Path $powershellZipPath
Expand-Archive -Path $powershellZipPath -DestinationPath $powershellPath
Push-Location "$powershellPath\powershell-master"
.\tools\Install-PowershellJvB.ps1
Pop-Location

# Install chocolatey if necessary
Write-Host "Looking for chocolatey."
$chocoCommand = Get-Command choco -ErrorAction SilentlyContinue
if ($chocoCommand -eq $null) {
    Write-Host "Chocolatey not found.  Installing."
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    Write-Host "Adding chocolatey to your path, for this session."
    $env:Path += ";C:\ProgramData\chocolatey\bin\"
}
else {
    Write-Host "Chocolatey found at $($chocoCommand.Source)."
}

# Install MSBuild if necessary
Write-Host "Looking for MsBuild."
if (Test-MsBuildInstalled) {
    Write-Host "MsBuild found."
}
else {
    Write-Host "Installing MsBuild."
    choco install microsoft-build-tools
}

# Install Docker for Windows if necessary
Write-Host "Checking for Operating System to determine what version to install."
$version = [System.Environment]::OSVersion.Version
Write-Host "Operating system is version $($version.Major), build $($version.Build)."
if ($version.Major -lt 10 -or $version.Build -lt 10586) {
    Write-Host "Looking for Docker Toolbox."
    $dockerCommand = Get-Command docker -ErrorAction SilentlyContinue
    if ($dockerCommand -eq $null) {
        Write-Host "Docker Toolbox not found.  Installing."
        choco install docker-toolbox -ia /COMPONENTS="kitematic,virtualbox,dockercompose"
    }
    else {
        Write-Host "Docker Toolbox found at $($dockerCommand.Source)."
    }
}
else {
    Write-Host "Looking for Docker for Windows."
    $dockerCommand = Get-Command docker -ErrorAction SilentlyContinue
    if ($dockerCommand -eq $null) {
        Write-Host "Docker for Windows not found.  Installing."
        choco install docker-for-windows
    }
    else {
        Write-Host "Docker for Windows found at $($dockerCommand.Source)."
    }
}

# Cleanup
Write-Host "Cleaning up."
Remove-Item -Path $tempPath -Recurse -Force

Write-Host "Prerequisites are now installed.  You are ready to run build and test scripts for this product."
