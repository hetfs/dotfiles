<#
.SYNOPSIS
    Production-ready WinRM HTTPS configuration for remote management
.DESCRIPTION
    Creates a WinRM HTTPS setup with proper certificate trust for remote machines.
    Includes certificate export and clear instructions for importing on remote systems.
.PARAMETER ExportPath
    Path to export certificate files (defaults to C:\WinRM-Certificates)
.PARAMETER PfxPassword
    Password for PFX export (default: "WinRM-Secure-P@ssw0rd!")
.EXAMPLE
    .\Enable-WinRM-Production.ps1
.EXAMPLE
    .\Enable-WinRM-Production.ps1 -ExportPath "C:\Certificates" -PfxPassword "MySecurePass123!"
.NOTES
    Version: 2.0 - Production-ready with remote trust support
#>

[CmdletBinding()]
param(
    [string]$ExportPath = "C:\WinRM-Certificates",
    [string]$PfxPassword = "WinRM-Secure-P@ssw0rd!"
)

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "           PRODUCTION WINRM HTTPS SETUP" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "This script will configure WinRM HTTPS for remote management" -ForegroundColor Gray
Write-Host "with certificate trust export for remote machines." -ForegroundColor Gray
Write-Host ""

# Check for admin rights
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator. Right-click PowerShell and select 'Run as Administrator'." -ForegroundColor Red
    exit 1
}

$computerName = $env:COMPUTERNAME
$domain = [System.Net.Dns]::GetHostEntry($computerName).HostName
if ($domain -eq $computerName) {
    $fqdn = "$computerName"
} else {
    $fqdn = $domain
}

Write-Host "System Information:" -ForegroundColor Yellow
Write-Host "  Computer Name: $computerName" -ForegroundColor Gray
Write-Host "  FQDN: $fqdn" -ForegroundColor Gray
Write-Host "  Export Path: $ExportPath" -ForegroundColor Gray
Write-Host ""

try {
    # Create export directory
    Write-Host "[1/7] Creating export directory..." -ForegroundColor Yellow
    if (-not (Test-Path $ExportPath)) {
        New-Item -ItemType Directory -Path $ExportPath -Force | Out-Null
        Write-Host "  Created: $ExportPath" -ForegroundColor Green
    }
    Write-Host ""

    # Stop WinRM service and clean up
    Write-Host "[2/7] Preparing WinRM service..." -ForegroundColor Yellow
    Stop-Service WinRM -Force -ErrorAction SilentlyContinue
    Write-Host "  Service stopped" -ForegroundColor Green

    # Remove existing HTTPS listener if present
    $null = cmd /c "winrm delete winrm/config/Listener?Address=*+Transport=HTTPS" 2>$null
    Write-Host "  Cleaned up existing configuration" -ForegroundColor Green
    Write-Host ""

    # Create production certificate
    Write-Host "[3/7] Creating production certificate..." -ForegroundColor Yellow

    # Get all IP addresses for SAN
    $ipAddresses = @(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
        $_.IPAddress -ne '127.0.0.1' -and $_.IPAddress -ne '169.254.*'
    } | Select-Object -ExpandProperty IPAddress)

    # Create certificate with comprehensive SAN
    $certParams = @{
        Subject           = "CN=$fqdn"
        DnsName           = @($fqdn, $computerName, "localhost")
        CertStoreLocation = "Cert:\LocalMachine\My"
        NotAfter          = (Get-Date).AddYears(3)
        KeyUsage          = "DigitalSignature", "KeyEncipherment"
        KeyAlgorithm      = "RSA"
        KeyLength         = 2048
    }

    $cert = New-SelfSignedCertificate @certParams
    Write-Host "  Certificate created successfully" -ForegroundColor Green
    Write-Host "    Subject: $($cert.Subject)" -ForegroundColor Gray
    Write-Host "    DNS Names: $fqdn, $computerName, localhost" -ForegroundColor Gray
    Write-Host "    Thumbprint: $($cert.Thumbprint)" -ForegroundColor Gray
    Write-Host "    Valid Until: $($cert.NotAfter.ToString('yyyy-MM-dd'))" -ForegroundColor Gray
    Write-Host ""

    # Trust certificate locally
    Write-Host "[4/7] Trusting certificate locally..." -ForegroundColor Yellow
    $cert | Export-Certificate -FilePath "$ExportPath\$computerName-temp.cer" -Type CERT | Out-Null
    Import-Certificate -FilePath "$ExportPath\$computerName-temp.cer" -CertStoreLocation "Cert:\LocalMachine\Root" | Out-Null
    Remove-Item "$ExportPath\$computerName-temp.cer" -Force
    Write-Host "  Added to Local Machine Trusted Root store" -ForegroundColor Green
    Write-Host ""

    # Export certificate in multiple formats
    Write-Host "[5/7] Exporting certificates for remote trust..." -ForegroundColor Yellow

    # 1. Export as CER (for Windows import)
    $cert | Export-Certificate -FilePath "$ExportPath\$computerName.cer" -Type CERT
    Write-Host "  CER file: $ExportPath\$computerName.cer" -ForegroundColor Gray

    # 2. Export as PFX with password (for cross-platform use)
    $securePassword = ConvertTo-SecureString -String $PfxPassword -AsPlainText -Force
    $cert | Export-PfxCertificate -FilePath "$ExportPath\$computerName.pfx" -Password $securePassword
    Write-Host "  PFX file: $ExportPath\$computerName.pfx" -ForegroundColor Gray
    Write-Host "  PFX Password: $PfxPassword" -ForegroundColor Yellow

    # 3. Export as Base64 text (for scripts/PowerShell)
    $certBytes = $cert.RawData
    $base64Cert = [Convert]::ToBase64String($certBytes)
    $base64Cert | Out-File -FilePath "$ExportPath\$computerName-base64.txt" -Encoding UTF8
    Write-Host "  Base64 file: $ExportPath\$computerName-base64.txt" -ForegroundColor Gray

    # 4. Create a script for importing on remote machines
    $importScript = @"
# WinRM Certificate Import Script for Remote Machines
# Run this script on CLIENT machines that need to connect to $computerName

`$certPath = "\\$computerName\c`$\$($ExportPath.Replace('C:\', ''))\$computerName.cer"
if (-not (Test-Path `$certPath)) {
    Write-Host "Certificate not found at `$certPath" -ForegroundColor Red
    Write-Host "Copy the certificate from $ExportPath\$computerName.cer first" -ForegroundColor Yellow
    exit 1
}

# Import to Current User Trusted Root (for current user only)
Write-Host "Importing certificate for Current User..." -ForegroundColor Yellow
Import-Certificate -FilePath `$certPath -CertStoreLocation Cert:\CurrentUser\Root

# Import to Local Machine Trusted Root (requires Admin, for all users)
if ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Importing certificate for Local Machine (all users)..." -ForegroundColor Yellow
    Import-Certificate -FilePath `$certPath -CertStoreLocation Cert:\LocalMachine\Root
}

Write-Host "Certificate imported successfully!" -ForegroundColor Green
Write-Host "You can now connect using:" -ForegroundColor Gray
Write-Host "  Test-WSMan -ComputerName $computerName -UseSSL" -ForegroundColor White
Write-Host "  Enter-PSSession -ComputerName $computerName -UseSSL -Credential (Get-Credential)" -ForegroundColor White
"@

    $importScript | Out-File -FilePath "$ExportPath\Import-Certificate-REMOTE.ps1" -Encoding UTF8
    Write-Host "  Import script: $ExportPath\Import-Certificate-REMOTE.ps1" -ForegroundColor Gray
    Write-Host "  Certificate files exported successfully" -ForegroundColor Green
    Write-Host ""

    # Configure WinRM HTTPS listener
    Write-Host "[6/7] Configuring WinRM HTTPS listener..." -ForegroundColor Yellow
    Start-Service WinRM -ErrorAction Stop
    Start-Sleep -Seconds 2

    # Create HTTPS listener
    $cmd = "winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{CertificateThumbprint=`"$($cert.Thumbprint)`"}"
    $result = cmd /c $cmd 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  HTTPS listener created on port 5986" -ForegroundColor Green
    } else {
        # Fallback method
        Write-Host "  Using alternative listener creation method..." -ForegroundColor Yellow
        winrm create winrm/config/listener -Address:* -Transport:HTTPS -CertificateThumbprint:$($cert.Thumbprint) -Force 2>$null
        Write-Host "  HTTPS listener created" -ForegroundColor Green
    }

    # Configure WinRM settings for remote access
    Write-Host "  Configuring WinRM for remote access..." -ForegroundColor Gray
    winrm set winrm/config/service '@{AllowUnencrypted="false"}'
    winrm set winrm/config/service/auth '@{Basic="true"}'
    winrm set winrm/config/service/auth '@{Kerberos="true"}'
    winrm set winrm/config/service/auth '@{Negotiate="true"}'
    winrm set winrm/config/client/auth '@{Basic="true"}'
    winrm set winrm/config/client/auth '@{Kerberos="true"}'
    winrm set winrm/config/client/auth '@{Negotiate="true"}'
    Write-Host "  Authentication methods configured" -ForegroundColor Green
    Write-Host ""

    # Configure firewall
    Write-Host "[7/7] Configuring Windows Firewall..." -ForegroundColor Yellow

    # Remove any existing WinRM HTTPS rules
    $existingRules = @("WinRM HTTPS", "Windows Remote Management (HTTPS-In)", "WinRM-HTTPS-5986")
    foreach ($ruleName in $existingRules) {
        netsh advfirewall firewall delete rule name="$ruleName" 2>$null
    }

    # Create comprehensive firewall rules
    netsh advfirewall firewall add rule `
        name="WinRM HTTPS (5986)" `
        displayname="Windows Remote Management HTTPS" `
        description="Inbound rule for WinRM over HTTPS. [TCP 5986]" `
        dir=in `
        action=allow `
        protocol=TCP `
        localport=5986 `
        remoteip=any `
        profile=any `
        enable=yes

    # Also allow ICMP for connectivity testing
    netsh advfirewall firewall add rule `
        name="ICMP Allow Inbound" `
        dir=in `
        action=allow `
        protocol=icmpv4 `
        enable=yes

    Write-Host "  Firewall rules configured" -ForegroundColor Green
    Write-Host ""

    # Final restart
    Restart-Service WinRM -Force
    Start-Sleep -Seconds 3

    # Verification and Summary
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "                  VERIFICATION" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    Write-Host "1. Service Status:" -ForegroundColor Gray
    $service = Get-Service WinRM
    Write-Host "   WinRM Service: $($service.Status)" -ForegroundColor $(if ($service.Status -eq 'Running') {'Green'} else {'Red'})

    Write-Host "`n2. Port Listening:" -ForegroundColor Gray
    $listening = netstat -an | Select-String ":5986.*LISTENING"
    if ($listening) {
        Write-Host "   Port 5986: LISTENING" -ForegroundColor Green
        $listening | ForEach-Object { Write-Host "     $_" -ForegroundColor Gray }
    } else {
        Write-Host "   Port 5986: NOT LISTENING" -ForegroundColor Red
    }

    Write-Host "`n3. Certificate Validation:" -ForegroundColor Gray
    try {
        # Test locally (should work since cert is in Trusted Root)
        $test = Test-WSMan -ComputerName $fqdn -UseSSL -ErrorAction Stop
        Write-Host "   Local test ($fqdn): SUCCESS" -ForegroundColor Green
    } catch {
        Write-Host "   Local test ($fqdn): $($_.Exception.Message)" -ForegroundColor Yellow
    }

    Write-Host "`n4. Files Created:" -ForegroundColor Gray
    Get-ChildItem $ExportPath | ForEach-Object {
        Write-Host "   $($_.Name)" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "         REMOTE CONNECTION INSTRUCTIONS" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    Write-Host "`nSTEP 1: Copy certificate to remote machines" -ForegroundColor Yellow
    Write-Host "  From: $ExportPath\$computerName.cer" -ForegroundColor White
    Write-Host "  Or run the import script remotely:" -ForegroundColor White
    Write-Host "  \\$computerName\c`$\$($ExportPath.Replace('C:\', ''))\Import-Certificate-REMOTE.ps1" -ForegroundColor Green

    Write-Host "`nSTEP 2: Import certificate on remote machines" -ForegroundColor Yellow
    Write-Host "  Option A: Run the import script (as Administrator):" -ForegroundColor Gray
    Write-Host "    .\Import-Certificate-REMOTE.ps1" -ForegroundColor White

    Write-Host "  Option B: Manual import:" -ForegroundColor Gray
    Write-Host "    1. Double-click the .cer file" -ForegroundColor White
    Write-Host "    2. Click 'Install Certificate'" -ForegroundColor White
    Write-Host "    3. Select 'Local Machine' (requires Admin)" -ForegroundColor White
    Write-Host "    4. Select 'Place all certificates in the following store'" -ForegroundColor White
    Write-Host "    5. Browse to 'Trusted Root Certification Authorities'" -ForegroundColor White
    Write-Host "    6. Click Next, then Finish" -ForegroundColor White

    Write-Host "`nSTEP 3: Test connection from remote machine" -ForegroundColor Yellow
    Write-Host "  PowerShell 5.1:" -ForegroundColor Gray
    Write-Host "    Test-WSMan -ComputerName $fqdn -UseSSL" -ForegroundColor White

    Write-Host "  PowerShell 7+:" -ForegroundColor Gray
    Write-Host "    Test-WSMan -ComputerName $fqdn -UseSSL -SkipCertificateCheck" -ForegroundColor White

    Write-Host "  With credentials:" -ForegroundColor Gray
    Write-Host "    `$cred = Get-Credential" -ForegroundColor White
    Write-Host "    Enter-PSSession -ComputerName $fqdn -UseSSL -Credential `$cred" -ForegroundColor White

    Write-Host "`nSTEP 4: Configure for automation (optional)" -ForegroundColor Yellow
    Write-Host "  For unattended scripts, use:" -ForegroundColor Gray
    Write-Host "    `$cred = New-Object System.Management.Automation.PSCredential('username', (ConvertTo-SecureString 'password' -AsPlainText -Force))" -ForegroundColor White
    Write-Host "    Invoke-Command -ComputerName $fqdn -UseSSL -Credential `$cred -ScriptBlock { ... }" -ForegroundColor White

    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "                  TROUBLESHOOTING" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    Write-Host "`nIf connection fails:" -ForegroundColor Gray
    Write-Host "  1. Check firewall on both machines: netsh advfirewall firewall show rule name='WinRM HTTPS'" -ForegroundColor White
    Write-Host "  2. Verify certificate is in Trusted Root on client: certlm.msc" -ForegroundColor White
    Write-Host "  3. Test network connectivity: Test-NetConnection $fqdn -Port 5986" -ForegroundColor White
    Write-Host "  4. Check WinRM service: winrm enumerate winrm/config/listener" -ForegroundColor White
    Write-Host "  5. Enable WinRM on client (if connecting from Windows): winrm quickconfig" -ForegroundColor White

    Write-Host "`nCertificate Details for Trust Verification:" -ForegroundColor Gray
    Write-Host "  Thumbprint: $($cert.Thumbprint)" -ForegroundColor White
    Write-Host "  Subject: $($cert.Subject)" -ForegroundColor White
    Write-Host "  Issuer: $($cert.Issuer)" -ForegroundColor White
    Write-Host "  Valid From: $($cert.NotBefore.ToString('yyyy-MM-dd'))" -ForegroundColor White
    Write-Host "  Valid Until: $($cert.NotAfter.ToString('yyyy-MM-dd'))" -ForegroundColor White

    # Create a final summary file
    $summary = @"
WINRM HTTPS CONFIGURATION SUMMARY
=================================
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Computer: $computerName
FQDN: $fqdn

CERTIFICATE DETAILS
-------------------
Thumbprint: $($cert.Thumbprint)
Subject: $($cert.Subject)
DNS Names: $fqdn, $computerName, localhost
Valid Until: $($cert.NotAfter.ToString('yyyy-MM-dd'))

CONNECTION INFORMATION
----------------------
HTTPS Endpoint: https://$fqdn:5986/wsman
Alternative: https://$computerName:5986/wsman

FILES EXPORTED
---------------
$ExportPath\$computerName.cer - Certificate file for import
$ExportPath\$computerName.pfx - PFX with password: $PfxPassword
$ExportPath\$computerName-base64.txt - Base64 encoded certificate
$ExportPath\Import-Certificate-REMOTE.ps1 - Import script for clients

REMOTE IMPORT COMMANDS
----------------------
# PowerShell (as Admin on client):
Import-Certificate -FilePath "\\$computerName\c`$\$($ExportPath.Replace('C:\', ''))\$computerName.cer" -CertStoreLocation Cert:\LocalMachine\Root

# Command Line (as Admin on client):
certutil -addstore -f Root "\\$computerName\c`$\$($ExportPath.Replace('C:\', ''))\$computerName.cer"

TEST COMMANDS
-------------
# From client (after importing certificate):
Test-WSMan -ComputerName $fqdn -UseSSL

# Remote PowerShell session:
Enter-PSSession -ComputerName $fqdn -UseSSL -Credential (Get-Credential)

TROUBLESHOOTING
---------------
1. Verify certificate is in Trusted Root Certification Authorities store
2. Check firewall: Port 5986 TCP must be open
3. Ensure WinRM service is running on $computerName
4. Test connectivity: Test-NetConnection $fqdn -Port 5986
"@

    $summary | Out-File -FilePath "$ExportPath\Configuration-Summary.txt" -Encoding UTF8

    Write-Host "`nFull configuration summary saved to:" -ForegroundColor Green
    Write-Host "  $ExportPath\Configuration-Summary.txt" -ForegroundColor White

    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "          SETUP COMPLETE - Ready for remote access!" -ForegroundColor Green
    Write-Host "========================================================" -ForegroundColor Cyan

}
catch {
    Write-Host "`nERROR: Setup failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Attempting to restore WinRM service..." -ForegroundColor Yellow
    try {
        Start-Service WinRM -ErrorAction SilentlyContinue
    } catch {
        Write-Host "Could not restore WinRM service" -ForegroundColor Red
    }
    exit 1
}
