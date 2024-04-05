# Determine the latest version tag from GitHub releases
$latestReleaseApiUrl = "https://api.github.com/repos/idk-cli/idk_terminal/releases/latest"
$latestVersion = Invoke-RestMethod -Uri $latestReleaseApiUrl | Select-Object -ExpandProperty tag_name

$scriptZipUrl = "https://github.com/idk-cli/idk_terminal/archive/refs/tags/$latestVersion.zip"

# Temporary directory for downloading and extracting the zip file
$tempDir = Join-Path -Path $env:TEMP -ChildPath "idk_script_tmp"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

# Temporary zip file name and path
$tempFileName = "idk.zip"
$tempFilePath = Join-Path -Path $tempDir -ChildPath $tempFileName

# Download the zip file
Invoke-WebRequest -Uri $scriptZipUrl -OutFile $tempFilePath

# Extract the zip file
Expand-Archive -Path $tempFilePath -DestinationPath $tempDir -Force

# Detect OS and Architecture
$os = "Windows" # Assuming Windows since it's a PowerShell script
$arch = if ([System.IntPtr]::Size -eq 8) { "x86_64" } else { "x86" } # Simplistic architecture detection

# Determine the executable name based on OS and Architecture
function Determine-ExecutableName {
    param (
        [string]$os,
        [string]$arch
    )
    if ($os -eq "Windows" -and $arch -eq "x86_64") {
        return "idk-windows-amd64.exe"
    } else {
        Write-Host "Unsupported architecture: $arch"
        exit 1
    }
}

$executableName = Determine-ExecutableName -os $os -arch $arch

# Assuming $HOME/.local/bin is your target installation directory. Adjust as necessary.
$installDir = Join-Path -Path $HOME -ChildPath ".local/bin"
New-Item -ItemType Directory -Force -Path $installDir | Out-Null
$installFile = "idk.exe" # Naming the executable for Windows

# Move the appropriate executable
$sourcePath = Join-Path -Path $tempDir -ChildPath "idk_terminal-$latestVersion/binaries/$executableName"
$destinationPath = Join-Path -Path $installDir -ChildPath $installFile
Move-Item -Path $sourcePath -Destination $destinationPath -Force

# Cleanup
Remove-Item -Path $tempDir -Recurse -Force

Write-Host ""
Write-Host "------------------------------"
Write-Host "IDK Installation Completed"
Write-Host "------------------------------"
Write-Host ""
