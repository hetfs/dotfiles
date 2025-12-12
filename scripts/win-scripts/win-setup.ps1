# ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐
# │ H │ │ E │ │ T │ │ F │ │ S │
# └───┘ └───┘ └───┘ └───┘ └───┘
#
# 🌍 HETFS LTD. - Code for a Brighter Future
# https://github.com/hetfs/dotfiles
#
# Windows Setup Script
# Ensures execution policy, Chocolatey, and OpenSSH server are installed and configured
# Idempotent, safe for automation or CI/CD pipelines

# ---------------------------------------------------------
# Helper function for verbose logging
# ---------------------------------------------------------
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $prefix = switch ($Level.ToUpper()) {
        "INFO"    { "ℹ️ [INFO]    " }
        "WARN"    { "⚠️ [WARN]    " }
        "ERROR"   { "❌ [ERROR]   " }
        "SUCCESS" { "✔️ [SUCCESS] " }
        default   { "ℹ️ [INFO]    " }
    }
    Write-Host "$prefix$Message"
}

# ---------------------------------------------------------
# Set PowerShell Execution Policy
# ---------------------------------------------------------
try {
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
    if ($currentPolicy -eq "RemoteSigned") {
        Write-Log "Execution policy already RemoteSigned for current user, skipping..."
    } else {
        Write-Log "Setting execution policy to RemoteSigned for current user..."
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
        Write-Log "Execution policy set successfully." "SUCCESS"
    }
} catch {
    Write-Log "Failed to set execution policy: $_" "ERROR"
    throw
}

# ---------------------------------------------------------
# Install Chocolatey
# ---------------------------------------------------------
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Log "Chocolatey is already installed, skipping..."
} else {
    Write-Log "Installing Chocolatey..."
    try {
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        Write-Log "Chocolatey installed successfully." "SUCCESS"
    } catch {
        Write-Log "Failed to install Chocolatey: $_" "ERROR"
        throw
    }
}

# ---------------------------------------------------------
# Install OpenSSH Server
# ---------------------------------------------------------
$sshService = Get-Service -Name sshd -ErrorAction SilentlyContinue
if ($sshService) {
    Write-Log "OpenSSH Server already installed, skipping..."
} else {
    Write-Log "Installing OpenSSH Server..."
    try {
        $openSSHPackages = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*' | Select-Object -ExpandProperty Name
        foreach ($pkg in $openSSHPackages) {
            Write-Log "Adding Windows Capability: $pkg"
            Add-WindowsCapability -Online -Name $pkg
        }

        # Start and configure sshd service
        Start-Service sshd
        Set-Service -Name sshd -StartupType Automatic
        Write-Log "OpenSSH service started and set to automatic." "SUCCESS"

        # Ensure Firewall rule exists
        if (-not (Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue)) {
            Write-Log "Creating OpenSSH firewall rule..."
            New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
            Write-Log "Firewall rule created successfully." "SUCCESS"
        } else {
            Write-Log "Firewall rule 'OpenSSH-Server-In-TCP' already exists, skipping..."
        }

    } catch {
        Write-Log "Failed to install or configure OpenSSH Server: $_" "ERROR"
        throw
    }
}
