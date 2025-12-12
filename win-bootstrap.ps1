# ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐
# │ H │ │ E │ │ T │ │ F │ │ S │
# └───┘ └───┘ └───┘ └───┘ └───┘
#
# 🌍 HETFS LTD. - Code for a Brighter Future
# https://github.com/hetfs/dotfiles
#
# Bootstrapper for Windows dotfiles setup
# Runs the main win-setup.ps1 script from scripts/win-scripts/
# Verifies Chocolatey & OpenSSH post-setup
# Always executed from project root

# ---------------------------------------------------------
# Helper function for logging
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
# Ensure script runs from project root
# ---------------------------------------------------------
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location -Path $ScriptRoot
Write-Log "Running win-bootstrap.ps1 from project root: $ScriptRoot" "SUCCESS"

# ---------------------------------------------------------
# Path to main setup script
# ---------------------------------------------------------
$WinSetupPath = Join-Path $ScriptRoot "scripts\win-scripts\win-setup.ps1"
if (-Not (Test-Path $WinSetupPath)) {
    Write-Log "win-setup.ps1 not found at $WinSetupPath" "ERROR"
    exit 1
}

# ---------------------------------------------------------
# Execution Policy Check
# ---------------------------------------------------------
$CurrentPolicy = Get-ExecutionPolicy -Scope Process
if ($CurrentPolicy -eq 'Restricted') {
    Write-Log "ExecutionPolicy is 'Restricted'. Temporarily setting to 'Bypass'." "WARN"
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
}

# ---------------------------------------------------------
# Run the main setup script
# ---------------------------------------------------------
try {
    Write-Log "Running win-setup.ps1..." "INFO"
    & $WinSetupPath
    Write-Log "win-setup.ps1 completed successfully." "SUCCESS"
} catch {
    Write-Log "Error occurred while executing win-setup.ps1: $_" "ERROR"
    exit 1
}

# ---------------------------------------------------------
# Post-setup verification
# ---------------------------------------------------------

# Verify Chocolatey
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Log "Chocolatey is installed and accessible." "SUCCESS"
} else {
    Write-Log "Chocolatey installation missing or not in PATH!" "ERROR"
}

# Verify OpenSSH service
$sshService = Get-Service -Name sshd -ErrorAction SilentlyContinue
if ($sshService -and $sshService.Status -eq 'Running') {
    Write-Log "OpenSSH service is installed and running." "SUCCESS"
} else {
    Write-Log "OpenSSH service not installed or not running!" "ERROR"
}

Write-Log "Windows bootstrap finished successfully." "SUCCESS"
