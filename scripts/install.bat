@echo off
setlocal

:: Define temporary directory for downloading and extracting the zip file
set "TEMP_DIR=%TEMP%\.idk_script_tmp"
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

:: Temporary zip file name
set "TEMP_FILE_NAME=idk.zip"

:: PowerShell command to download the latest version tag from GitHub
set "PS_SCRIPT=Invoke-WebRequest -Uri 'https://api.github.com/repos/idk-cli/idk_terminal/releases/latest' -UseBasicParsing | ConvertFrom-Json | Select-Object -ExpandProperty tag_name"
for /f "delims=" %%i in ('powershell -Command "%PS_SCRIPT%"') do set SCRIPT_LATEST_VERSION=%%i

:: Construct the zip file download URL
set "SCRIPT_ZIP_URL=https://github.com/idk-cli/idk_terminal/archive/refs/tags/%SCRIPT_LATEST_VERSION%.zip"

echo Downloading IDK...

:: Download the zip file using PowerShell
powershell -Command "Invoke-WebRequest -Uri '%SCRIPT_ZIP_URL%' -OutFile '%TEMP_DIR%\%TEMP_FILE_NAME%'"

:: Define executable name
set "EXECUTABLE_NAME=idk-windows-amd64.exe"

:: Extract the zip file to the temporary directory
powershell -Command "Expand-Archive -Path '%TEMP_DIR%\%TEMP_FILE_NAME%' -DestinationPath '%TEMP_DIR%'"

:: Define install directory
set "INSTALL_DIR=%LOCALAPPDATA%\Programs\idk"
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

:: Move the appropriate executable to the install directory
move /Y "%TEMP_DIR%\idk_terminal-%SCRIPT_LATEST_VERSION%\binaries\%EXECUTABLE_NAME%" "%INSTALL_DIR%\idk.exe"

:: Cleanup
rd /s /q "%TEMP_DIR%"

echo.
echo Installation Completed
echo.

:: Add the install directory to the user PATH environment variable if not already present
setx PATH "%PATH%;%INSTALL_DIR%"

endlocal
