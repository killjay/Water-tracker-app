# Android SDK Setup Script for Flutter
# This script helps set up Android SDK for building APKs

Write-Host "=== Android SDK Setup for Flutter ===" -ForegroundColor Cyan
Write-Host ""

$sdkPath = "$env:LOCALAPPDATA\Android\Sdk"
$cmdlineToolsPath = "$sdkPath\cmdline-tools\latest"

# Set environment variables
$env:ANDROID_HOME = $sdkPath
$env:ANDROID_SDK_ROOT = $sdkPath
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $sdkPath, "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $sdkPath, "User")

Write-Host "ANDROID_HOME set to: $sdkPath" -ForegroundColor Green

# Check if SDK directory exists
if (-not (Test-Path $sdkPath)) {
    New-Item -ItemType Directory -Force -Path $sdkPath | Out-Null
    Write-Host "Created SDK directory: $sdkPath" -ForegroundColor Green
}

# Check if command line tools exist
if (-not (Test-Path $cmdlineToolsPath)) {
    Write-Host ""
    Write-Host "Command line tools not found. Installing..." -ForegroundColor Yellow
    Write-Host "This may take a few minutes..." -ForegroundColor Yellow
    
    $toolsZip = "$sdkPath\cmdline-tools.zip"
    $toolsUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
    
    try {
        Invoke-WebRequest -Uri $toolsUrl -OutFile $toolsZip -UseBasicParsing
        Expand-Archive -Path $toolsZip -DestinationPath "$sdkPath\cmdline-tools-temp" -Force
        
        # Move to correct location
        if (Test-Path "$sdkPath\cmdline-tools-temp\cmdline-tools") {
            Move-Item -Path "$sdkPath\cmdline-tools-temp\cmdline-tools\*" -Destination "$cmdlineToolsPath" -Force -ErrorAction SilentlyContinue
        }
        
        Remove-Item $toolsZip -ErrorAction SilentlyContinue
        Remove-Item "$sdkPath\cmdline-tools-temp" -Recurse -Force -ErrorAction SilentlyContinue
        
        Write-Host "Command line tools installed!" -ForegroundColor Green
    } catch {
        Write-Host "Failed to download command line tools automatically." -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please download manually from:" -ForegroundColor Yellow
        Write-Host "https://developer.android.com/studio#command-tools" -ForegroundColor Yellow
        exit 1
    }
}

# Add to PATH
$newPath = "$cmdlineToolsPath\bin;$sdkPath\platform-tools"
if ($env:PATH -notlike "*$newPath*") {
    $env:PATH = "$newPath;$env:PATH"
    [Environment]::SetEnvironmentVariable("PATH", "$newPath;$env:PATH", "User")
}

# Check if sdkmanager is available
$sdkmanager = "$cmdlineToolsPath\bin\sdkmanager.bat"
if (Test-Path $sdkmanager) {
    Write-Host ""
    Write-Host "Installing required Android SDK components..." -ForegroundColor Yellow
    Write-Host "This will download ~1GB of files. Please be patient..." -ForegroundColor Yellow
    Write-Host ""
    
    # Accept licenses first
    Write-Host "Accepting Android SDK licenses..." -ForegroundColor Cyan
    & $sdkmanager --licenses | ForEach-Object {
        if ($_ -match "y/n") {
            "y"
        } else {
            $_
        }
    } | Out-Null
    
    # Install required components
    Write-Host ""
    Write-Host "Installing platform-tools, platform, and build-tools..." -ForegroundColor Cyan
    & $sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
    
    Write-Host ""
    Write-Host "=== Setup Complete! ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now build your APK with:" -ForegroundColor Cyan
    Write-Host "  flutter build apk --release" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "SDK Manager not found. Please:" -ForegroundColor Yellow
    Write-Host "1. Launch Android Studio" -ForegroundColor White
    Write-Host "2. Complete the setup wizard" -ForegroundColor White
    Write-Host "3. Or manually install command line tools" -ForegroundColor White
    Write-Host ""
    Write-Host "Then run this script again." -ForegroundColor Yellow
}

# Configure Flutter
Write-Host ""
Write-Host "Configuring Flutter..." -ForegroundColor Cyan
flutter config --android-sdk $sdkPath

Write-Host ""
Write-Host "Running flutter doctor..." -ForegroundColor Cyan
flutter doctor
