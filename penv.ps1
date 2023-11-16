# Copyright (c) 2023 Raul Diaz
# All rights reserved unless a LICENSE file exists in the repository
# in which case a license is granted as per the LICENSE file contents
#####################################################################

# Place this file in ${HOME}/.envs
# Execute these commands in PowerShell:
# PS> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
# PS> . ${HOME}/.envs/penv.ps1

# Environment directory variable
$EnvDirName = ".envs"

# File to hold aliases
$AliasFile = ".aliases.ps1"
$AliasFilePath = "$HOME/$AliasFile"

# Ensure the alias file exists
if (-not (Test-Path $AliasFilePath)) {
    New-Item -ItemType File -Path $AliasFilePath
}

# Function to add an alias
function Add-Alias {
    param(
        [string]$envName
    )
    $aliasName = "env$envName"
    $activateCommand = "$HOME/$EnvDirName/$envName/Scripts/Activate.ps1"
    $aliasContent = "`nfunction $aliasName { &$activateCommand }"

    # Add environment activation alias
    Add-Content $AliasFilePath $aliasContent
}

# Function to add the penv alias
function Add-PenvAlias {
    $penvCommand = "$HOME/$EnvDirName/penv.ps1"
    $penvAlias = "`nfunction penv { &`"$penvCommand`" }"

    # Check if penv alias already exists, if not, add it
    if (-not (Select-String -Path $AliasFilePath -Pattern "function penv")) {
        Add-Content $AliasFilePath $penvAlias
    }
}

# Function to self-install the script
function Self-Install {
    $scriptPath = $MyInvocation.MyCommand.Path
    $targetPath = "$HOME/$EnvDirName/penv.ps1"

    # Check if the script is not already in the target location
    if ($scriptPath -ne $targetPath) {
        Copy-Item $scriptPath $targetPath
        Write-Host "penv.ps1 has been copied to $targetPath"
    }
}

# Create the environment directory if it doesn't exist
New-Item -ItemType Directory -Path "$HOME/$EnvDirName" -Force

# Self-install the script into the $EnvDirName
Self-Install

# Add the penv alias
Add-PenvAlias

# Create the Python environment
if ($args.Count -ne 1) {
    Write-Host "Usage: penv environment_name"
} else {
    $EnvName = $args[0]
    $AliasName = "env$EnvName"
    $EnvironmentDir = "$HOME/$EnvDirName/$EnvName"

    # Create the virtual environment
    python -m venv $EnvironmentDir

    # Add the environment activation alias
    Add-Alias $EnvName

    Write-Host "Python env $EnvName created and alias $AliasName added that activates this env"
}

# Source the alias file to load aliases
. $AliasFilePath
