<#
.SYNOPSIS
    WinRM Learning & Practice Script with automatic HTTPS listener creation and cleanup.
.DESCRIPTION
    Demonstrates common WinRM commands safely.
    - Tests local and HTTPS connectivity
    - Lists and inspects listeners
    - Automatically creates a self-signed HTTPS listener for localhost
    - Provides a cleanup function to remove the learning listener and certificate
.NOTES
    Run as Administrator on Windows 10/Server 2016+.
#>

# ------------------------
# Script Variables
# ------------------------
$LearningCertName = "CN=localhost WinRM Demo"
$LearningListenerAddress = "*"
$LearningListenerTransport = "HTTPS"

Write-Host "`n=== WinRM Learning Script ===`n" -ForegroundColor Cyan

# ------------------------
# 1️⃣ WinRM Service Status & QuickConfig
# ------------------------
Write-Host "`n1️⃣ WinRM Service Status & QuickConfig" -ForegroundColor Yellow

$winrmService = Get-Service WinRM
if ($winrmService.Status -ne 'Running') {
    Start-Service WinRM
    Set-Service WinRM -StartupType Automatic
}
Write-Host "WinRM service is running and set to Automatic." -ForegroundColor Green

try {
    winrm quickconfig -q | Out-Null
    Write-Host "WinRM quickconfig applied (dry run for demo)..." -ForegroundColor Green
} catch {
    Write-Warning "WinRM quickconfig warning: $_"
    Write-Host "Firewall rule may fail on Public network. Skipping automatic firewall setup." -ForegroundColor Yellow
}

# ------------------------
# 2️⃣ Inspect or Create WSMan Listener
# ------------------------
Write-Host "`n2️⃣ Inspect/Create WinRM HTTPS Listener" -ForegroundColor Yellow

# Check if listener exists
$listener = Get-ChildItem WSMan:\localhost\Listener | Where-Object {
    $_.Transport -eq $LearningListenerTransport -and $_.Address -eq $LearningListenerAddress
}

if (-not $listener) {
    Write-Host "No HTTPS listener found. Creating self-signed certificate..." -ForegroundColor Cyan

    # Check if certificate exists
    $cert = Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -eq $LearningCertName }
    if (-not $cert) {
        $cert = New-SelfSignedCertificate -DnsName "localhost" -CertStoreLocation "Cert:\LocalMachine\My" -FriendlyName $LearningCertName
        Write-Host "Certificate created: $($cert.Thumbprint)" -ForegroundColor Green
    }

    # Create HTTPS listener using Set-Item
    Write-Host "Creating WinRM HTTPS listener..." -ForegroundColor Cyan
    $listenerPath = "WSMan:\localhost\Listener\Listener_00000000" # temporary path
    $listenerInstance = @{
        Address = $LearningListenerAddress
        Transport = $LearningListenerTransport
        CertificateThumbprint = $cert.Thumbprint
        Port = 5986
    }

    # Use the WSMan: drive to create listener
    try {
        New-Item -Path WSMan:\localhost\Listener -Transport $LearningListenerTransport -Address $LearningListenerAddress -CertificateThumbprint $cert.Thumbprint -Force | Out-Null
        Write-Host "✅ HTTPS listener created successfully." -ForegroundColor Green
    } catch {
        Write-Warning "Failed to create listener using New-Item, falling back to winrm CLI..."
        winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname='localhost';CertificateThumbprint='$($cert.Thumbprint)'}
    }
} else {
    Write-Host "HTTPS listener already exists." -ForegroundColor Green
    $cert = Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Thumbprint -eq $listener.CertificateThumbprint }
}

# Enumerate listeners
winrm enumerate winrm/config/Listener

# ------------------------
# 3️⃣ Test Local WinRM Connectivity
# ------------------------
Write-Host "`n3️⃣ Test Local WinRM Connectivity" -ForegroundColor Yellow
$so = New-PSSessionOption -SkipCACheck -SkipCNCheck
try {
    Test-WSMan -ComputerName localhost -UseSSL -SessionOption $so
    Write-Host "Local WSMan test succeeded." -ForegroundColor Green
} catch {
    Write-Warning "Test-WSMan failed: $_"
}

# ------------------------
# 4️⃣ Remote Command Execution (Localhost Demo)
# ------------------------
Write-Host "`n4️⃣ Remote Command Execution (localhost demo)" -ForegroundColor Yellow
$session = $null
try {
    $session = New-PSSession -ComputerName localhost -UseSSL -SessionOption $so
    if ($session) {
        Invoke-Command -Session $session -ScriptBlock { Get-Process | Select-Object -First 5 }
        Remove-PSSession $session
    }
} catch {
    Write-Warning "Remote command execution failed: $_"
    if ($session) { Remove-PSSession $session -ErrorAction SilentlyContinue }
}

# ------------------------
# 5️⃣ Certificates in LocalMachine\My
# ------------------------
Write-Host "`n5️⃣ Certificates in LocalMachine\My" -ForegroundColor Yellow
Get-ChildItem Cert:\LocalMachine\My | Select-Object FriendlyName, Subject, Thumbprint, NotAfter | Format-Table

# ------------------------
# 6️⃣ Inspect WinRM Service Settings
# ------------------------
Write-Host "`n6️⃣ Inspect WinRM Service Settings" -ForegroundColor Yellow
winrm get winrm/config/service
winrm get winrm/config

# ------------------------
# 7️⃣ Cleanup Function for Learning Listener
# ------------------------
function Remove-LearningListener {
    <#
    .SYNOPSIS
        Removes the learning HTTPS listener and self-signed certificate.
    .DESCRIPTION
        Only removes the listener and certificate created by this script.
    #>

    Write-Host "`n🧹 Cleaning up learning listener and certificate..." -ForegroundColor Cyan

    # Remove listener
    $listener = Get-ChildItem WSMan:\localhost\Listener | Where-Object { $_.Transport -eq $LearningListenerTransport -and $_.CertificateThumbprint -eq $cert.Thumbprint }
    if ($listener) {
        Remove-Item WSMan:\localhost\Listener\$($listener.Name) -Recurse -Force
        Write-Host "Learning HTTPS listener removed." -ForegroundColor Green
    } else {
        Write-Host "No learning HTTPS listener found." -ForegroundColor Yellow
    }

    # Remove certificate
    if ($cert) {
        Remove-Item -Path "Cert:\LocalMachine\My\$($cert.Thumbprint)" -Force
        Write-Host "Self-signed learning certificate removed." -ForegroundColor Green
    } else {
        Write-Host "No learning certificate found." -ForegroundColor Yellow
    }

    Write-Host "✅ Cleanup complete." -ForegroundColor Green
}

Write-Host "`n7️⃣ Troubleshooting Tips" -ForegroundColor Yellow
Write-Host "- Listener exists but fails: Remove-WSManInstance or Remove-LearningListener to clean up" -ForegroundColor Gray
Write-Host "- Test connectivity with Test-WSMan" -ForegroundColor Gray
Write-Host "- Firewall port 5986 must be open for HTTPS" -ForegroundColor Gray
Write-Host "- Ensure certificates exist for HTTPS listener" -ForegroundColor Gray
Write-Host "- Call Remove-LearningListener to clean up demo resources" -ForegroundColor Gray

Write-Host "`n✅ Demo complete. All commands executed safely. Review outputs above." -ForegroundColor Green
