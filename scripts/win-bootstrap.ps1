<#
.SYNOPSIS
Windows bootstrap script for Ansible provisioning
#>

# Require admin privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process pwsh -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Install prerequisites
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

# Install Chocolatey if missing
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    refreshenv
}

# Install Ansible and Git
choco install -y ansible git

# Clone repository
$repoUrl = "https://github.com/hetfs/dotfiles.git"
$repoPath = Join-Path $env:USERPROFILE "dotfiles"
if (-not (Test-Path $repoPath)) {
    git clone $repoUrl $repoPath
}

# Execute Ansible playbook
Set-Location (Join-Path $repoPath "ansible")
ansible-playbook playbooks\windows\main.yml --extra-vars "vault_password_file=$env:USERPROFILE\.vault_pass"
