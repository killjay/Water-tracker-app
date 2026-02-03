# Android SDK Installation Script
# Run this in PowerShell (as Administrator recommended)

Write-Host "=== Android SDK Installation for Flutter ===" -ForegroundColor Cyan
Write-Host ""

$sdkPath = "$env:LOCALAPPDATA\Android\Sdk"
$toolsUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$toolsZip = "$sdkPath\cmdline-tools.zip"

# Create SDK directory
if (-not (Test-Path $sdkPath)) {
    New-Item -ItemType Directory -Force -Path $sdkPath | Out-Null
    Write-Host "Created SDK directory: $sdkPath" -ForegroundColor Green
}

# Set environment variables
$env:ANDROID_HOME = $sdkPath
$env:ANDROID_SDK_ROOT = $sdkPath
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $sdkPath, "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $sdkPath, "User")

Write-Host "ANDROID_HOME set to: $sdkPath" -ForegroundColor Green
Write-Host ""

# Download command line tools
if (-not (Test-Path "$sdkPath\cmdline-tools\latest\bin\sdkmanager.bat")) {
    Write-Host "Downloading Android SDK Command Line Tools (~100MB)..." -ForegroundColor Yellow
    Write-Host "This may take several minutes depending on your connection..." -ForegroundColor Yellow
    Write-Host ""
    
    try {
        Invoke-WebRequest -Uri $toolsUrl -OutFile $toolsZip -UseBasicParsing
        Write-Host "Download complete! Extracting..." -ForegroundColor Green
        
        # Extract
        Expand-Archive -Path $toolsZip -DestinationPath "$sdkPath\temp" -Force
        
        # Move to correct location
        if (Test-Path "$sdkPath\temp\cmdline-tools") {
            New-Item -ItemType Directory -Force -Path "$sdkPath\cmdline-tools\latest" | Out-Null
            Move-Item -Path "$sdkPath\temp\cmdline-tools\*" -Destination "$sdkPath\cmdline-tools\latest" -Force
        }
        
        Remove-Item "$sdkPath\temp" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item $toolsZip -ErrorAction SilentlyContinue
        
        Write-Host "Extraction complete!" -ForegroundColor Green
        Write-Host ""
    } catch {
        Write-Host "Download failed: $_" -ForegroundColor Red
        Write-Host "Please check your internet connection and try again." -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "Command line tools already installed." -ForegroundColor Green
    Write-Host ""
}

# Install SDK components
$sdkmanager = "$sdkPath\cmdline-tools\latest\bin\sdkmanager.bat"
if (Test-Path $sdkmanager) {
    Write-Host "Installing Android SDK components..." -ForegroundColor Cyan
    Write-Host "This will download ~1GB. Please be patient..." -ForegroundColor Yellow
    Write-Host ""
    
    # Add to PATH
    $binPath = "$sdkPath\cmdline-tools\latest\bin"
    if ($env:PATH -notlike "*$binPath*") {
        $env:PATH = "$binPath;$env:PATH"
    }
    
    # Accept licenses
    Write-Host "Accepting Android SDK licenses..." -ForegroundColor Yellow
    $licenses = "y" * 10  # Accept all licenses
    $licenses | & $sdkmanager --licenses
    
    Write-Host ""
    Write-Host "Installing platform-tools, Android 34 platform, and build-tools..." -ForegroundColor Yellow
    & $sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
    
    Write-Host ""
    Write-Host "=== Installation Complete! ===" -ForegroundColor Green
    Write-Host ""
    
    # Configure Flutter
    Write-Host "Configuring Flutter..." -ForegroundColor Cyan
    flutter config --android-sdk $sdkPath
    
    Write-Host ""
    Write-Host "Running flutter doctor..." -ForegroundColor Cyan
    flutter doctor
    
    Write-Host ""
    Write-Host "You can now build your debug APK with:" -ForegroundColor Green
    Write-Host "  flutter build apk --debug" -ForegroundColor White
} else {
    Write-Host "ERROR: SDK Manager not found at: $sdkmanager" -ForegroundColor Red
    Write-Host "Please check the installation and try again." -ForegroundColor Yellow
    exit 1
}
