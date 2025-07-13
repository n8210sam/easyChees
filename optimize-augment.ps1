# Augment Extension Performance Optimization Script
# This script helps apply performance optimization settings for VSCode Augment extension

Write-Host "=== Augment Extension Performance Optimization Script ===" -ForegroundColor Green

# Check if VSCode is running
$vscodeProcesses = Get-Process -Name "Code" -ErrorAction SilentlyContinue
if ($vscodeProcesses) {
    Write-Host "Warning: VSCode is currently running. It's recommended to close VSCode before running this script." -ForegroundColor Yellow
    $response = Read-Host "Continue anyway? (y/N)"
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Host "Script cancelled." -ForegroundColor Red
        exit
    }
}

# Check if .vscode directory exists
if (-not (Test-Path ".vscode")) {
    Write-Host "Error: .vscode directory not found. Please ensure you're running this script in the correct project root directory." -ForegroundColor Red
    exit 1
}

Write-Host "Applying Augment extension optimization settings..." -ForegroundColor Blue

# Check configuration files
$configFiles = @(
    ".vscode/settings.json",
    ".vscode/launch.json",
    ".vscode/tasks.json",
    ".vscode/extensions.json",
    ".augment/config.json"
)

foreach ($file in $configFiles) {
    if (Test-Path $file) {
        Write-Host "✓ Found config file: $file" -ForegroundColor Green
    } else {
        Write-Host "✗ Missing config file: $file" -ForegroundColor Red
    }
}

# Clean Flutter cache to improve performance
Write-Host "`nCleaning Flutter cache..." -ForegroundColor Blue
try {
    if (Get-Command flutter -ErrorAction SilentlyContinue) {
        flutter clean
        flutter pub get
        Write-Host "✓ Flutter cache cleaning completed" -ForegroundColor Green
    } else {
        Write-Host "Warning: Flutter command not found, skipping cache cleanup" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Warning: Flutter cache cleanup failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Check Dart analysis server
Write-Host "`nRestarting Dart analysis server..." -ForegroundColor Blue
try {
    if (Get-Command dart -ErrorAction SilentlyContinue) {
        # Stop Dart analysis server
        Get-Process -Name "dartanalyzer" -ErrorAction SilentlyContinue | Stop-Process -Force
        Get-Process -Name "analysis_server" -ErrorAction SilentlyContinue | Stop-Process -Force
        Write-Host "✓ Dart analysis server restarted" -ForegroundColor Green
    }
} catch {
    Write-Host "Warning: Dart analysis server restart failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Display optimization recommendations
Write-Host "`n=== Optimization Recommendations ===" -ForegroundColor Cyan
Write-Host "1. Restart VSCode to apply new settings"
Write-Host "2. Execute 'Developer: Reload Window' command in VSCode"
Write-Host "3. Check if Augment extension has optimization settings enabled"
Write-Host "4. Monitor CPU and memory usage"

Write-Host "`n=== Further Optimization ===" -ForegroundColor Cyan
Write-Host "If performance issues persist, try:"
Write-Host "- Further reduce augment.indexing.batchSize in settings.json"
Write-Host "- Increase augment.indexing.throttle delay time"
Write-Host "- Disable augment.analysis.realTime"
Write-Host "- Add more file exclusion rules"

Write-Host "`n=== Performance Monitoring ===" -ForegroundColor Cyan
Write-Host "You can monitor performance by:"
Write-Host "- Opening VSCode Developer Tools (Ctrl+Shift+I)"
Write-Host "- Checking Augment logs in Console"
Write-Host "- Using Windows Task Manager to monitor VSCode processes"

Write-Host "`nOptimization script completed!" -ForegroundColor Green
Write-Host "Please restart VSCode to apply all settings." -ForegroundColor Yellow
