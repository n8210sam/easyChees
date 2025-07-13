# Version Manager Script - Auto update Flutter app version
# Usage: .\scripts\version-manager.ps1 [patch|minor|major] [description]
# Example: .\scripts\version-manager.ps1 patch "Fix sudoku auto-complete feature"

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("patch", "minor", "major")]
    [string]$VersionType,

    [Parameter(Mandatory=$false)]
    [string]$Description = ""
)

Write-Host "=== Sudoku Game Version Manager ===" -ForegroundColor Green

# Check if in correct directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "Error: Please run this script in project root directory" -ForegroundColor Red
    exit 1
}

# Read current version
$pubspecContent = Get-Content "pubspec.yaml" -Raw
$versionMatch = [regex]::Match($pubspecContent, 'version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)')

if (-not $versionMatch.Success) {
    Write-Host "Error: Cannot parse version number in pubspec.yaml" -ForegroundColor Red
    exit 1
}

$major = [int]$versionMatch.Groups[1].Value
$minor = [int]$versionMatch.Groups[2].Value
$patch = [int]$versionMatch.Groups[3].Value
$build = [int]$versionMatch.Groups[4].Value

$currentVersion = "$major.$minor.$patch"
Write-Host "Current version: $currentVersion+$build" -ForegroundColor Blue

# Calculate new version
switch ($VersionType) {
    "major" {
        $major++
        $minor = 0
        $patch = 0
    }
    "minor" {
        $minor++
        $patch = 0
    }
    "patch" {
        $patch++
    }
}
$build++

$newVersion = "$major.$minor.$patch"
$newFullVersion = "$newVersion+$build"

Write-Host "New version: $newVersion+$build" -ForegroundColor Green

# Update pubspec.yaml
$newPubspecContent = $pubspecContent -replace 'version:\s*\d+\.\d+\.\d+\+\d+', "version: $newFullVersion"
Set-Content "pubspec.yaml" $newPubspecContent -Encoding UTF8

# Update version display in main.dart
$mainDartPath = "lib\main.dart"
if (Test-Path $mainDartPath) {
    $mainContent = Get-Content $mainDartPath -Raw
    $newMainContent = $mainContent -replace "v\d+\.\d+\.\d+", "v$newVersion"
    Set-Content $mainDartPath $newMainContent -Encoding UTF8
    Write-Host "✓ Updated version display in main.dart" -ForegroundColor Green
}

# Update version history file
$versionHistoryPath = "CHANGELOG.md"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$changelogEntry = @"
## [$newVersion] - $timestamp

### Change type: $VersionType
$Description

"@

if (Test-Path $versionHistoryPath) {
    $existingContent = Get-Content $versionHistoryPath -Raw
    $newContent = $changelogEntry + "`n" + $existingContent
} else {
    $newContent = @"
# Version History

$changelogEntry
"@
}

Set-Content $versionHistoryPath $newContent -Encoding UTF8

Write-Host "✓ Updated pubspec.yaml" -ForegroundColor Green
Write-Host "✓ Updated version history" -ForegroundColor Green

# Display summary
Write-Host "`n=== Version Update Complete ===" -ForegroundColor Cyan
Write-Host "Version: $currentVersion -> $newVersion" -ForegroundColor Yellow
Write-Host "Build: $($build-1) -> $build" -ForegroundColor Yellow
Write-Host "Update type: $VersionType" -ForegroundColor Yellow
if ($Description) {
    Write-Host "Description: $Description" -ForegroundColor Yellow
}

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Run 'flutter pub get' to update dependencies"
Write-Host "2. Run 'flutter build web' to rebuild application"
Write-Host "3. Test new features"
Write-Host "4. Commit changes to version control"
