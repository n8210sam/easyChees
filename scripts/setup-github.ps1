# GitHub Setup Script for Android APK Build
# This script helps you set up GitHub repository and push code for automatic APK building

param(
    [Parameter(Mandatory=$false)]
    [string]$RepoName = "easychees-sudoku",
    
    [Parameter(Mandatory=$false)]
    [string]$GitHubUsername = ""
)

Write-Host "=== GitHub Setup for Android APK Build ===" -ForegroundColor Green

# Check if we're in the correct directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "Error: Please run this script in project root directory" -ForegroundColor Red
    exit 1
}

# Check if git is installed
try {
    git --version | Out-Null
} catch {
    Write-Host "Error: Git is not installed. Please install Git first." -ForegroundColor Red
    Write-Host "Download from: https://git-scm.com/download/windows" -ForegroundColor Yellow
    exit 1
}

Write-Host "Step 1: Initializing Git repository..." -ForegroundColor Blue

# Initialize git if not already done
if (-not (Test-Path ".git")) {
    git init
    Write-Host "✓ Git repository initialized" -ForegroundColor Green
} else {
    Write-Host "✓ Git repository already exists" -ForegroundColor Green
}

Write-Host "`nStep 2: Adding files to Git..." -ForegroundColor Blue

# Add all files
git add .

# Check if there are changes to commit
$status = git status --porcelain
if ($status) {
    git commit -m "Initial commit: Sudoku game with auto-complete feature and Android support"
    Write-Host "✓ Files committed to Git" -ForegroundColor Green
} else {
    Write-Host "✓ No changes to commit" -ForegroundColor Green
}

Write-Host "`nStep 3: GitHub Repository Setup" -ForegroundColor Blue

if (-not $GitHubUsername) {
    Write-Host "Please provide your GitHub username:" -ForegroundColor Yellow
    $GitHubUsername = Read-Host "GitHub Username"
}

$repoUrl = "https://github.com/$GitHubUsername/$RepoName.git"

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Create a new repository on GitHub:" -ForegroundColor Yellow
Write-Host "   - Go to https://github.com/new" -ForegroundColor Cyan
Write-Host "   - Repository name: $RepoName" -ForegroundColor Cyan
Write-Host "   - Description: 數獨遊戲 - 具有自動完成功能的 Flutter 應用" -ForegroundColor Cyan
Write-Host "   - Make it Public or Private (your choice)" -ForegroundColor Cyan
Write-Host "   - DO NOT add README, .gitignore, or license (we already have them)" -ForegroundColor Cyan
Write-Host "   - Click 'Create repository'" -ForegroundColor Cyan

Write-Host "`n2. After creating the repository, run these commands:" -ForegroundColor Yellow
Write-Host "git remote add origin $repoUrl" -ForegroundColor Cyan
Write-Host "git branch -M main" -ForegroundColor Cyan
Write-Host "git push -u origin main" -ForegroundColor Cyan

Write-Host "`n3. GitHub Actions will automatically build your APK!" -ForegroundColor Yellow
Write-Host "   - Go to your repository → Actions tab" -ForegroundColor Cyan
Write-Host "   - Wait for the build to complete (5-10 minutes)" -ForegroundColor Cyan
Write-Host "   - Download the APK from the Artifacts section" -ForegroundColor Cyan

Write-Host "`nRepository URL will be: $repoUrl" -ForegroundColor Green
Write-Host "`nReady to proceed? Follow the steps above!" -ForegroundColor Green
