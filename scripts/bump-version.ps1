# Quick version update script - defaults to patch version update
# Usage: .\scripts\bump-version.ps1 ["description"]

param(
    [Parameter(Mandatory=$false)]
    [string]$Description = "Feature update"
)

# Call main version manager script
& "$PSScriptRoot\version-manager.ps1" -VersionType "patch" -Description $Description
