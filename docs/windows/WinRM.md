# WinRM HTTPS Configuration Script

## Overview

This PowerShell script configures Windows Remote Management (WinRM) over HTTPS with a self-signed certificate, enabling secure remote PowerShell sessions. The script creates a production-ready setup with proper certificate trust for remote machine access.

## Features

- ✅ Creates self-signed certificate with proper Subject Alternative Names (SAN)
- ✅ Configures WinRM HTTPS listener on port 5986
- ✅ Exports certificates in multiple formats (CER, PFX, Base64)
- ✅ Creates import scripts for remote machines
- ✅ Configures Windows Firewall rules
- ✅ Provides comprehensive verification and troubleshooting
- ✅ Idempotent - can be run multiple times safely

## Prerequisites

- Windows PowerShell 5.1 or higher (run as Administrator)
- Windows Server 2012 R2 or later / Windows 10 or later
- Administrator privileges on the target machine

## Quick Start

### 1. Run the Configuration Script

```powershell
# Download or create the script, then run:
.\Enable-WinRM-Production.ps1
```

### 2. Using Parameters

```powershell
# Custom export path and password
.\Enable-WinRM-Production.ps1 -ExportPath "C:\Certificates" -PfxPassword "CustomPassword123!"
```

## What the Script Does

### 1. **Certificate Creation**
- Creates certificate with CN matching the FQDN
- Adds SAN entries for: FQDN, ComputerName, localhost
- Valid for 3 years
- Stores in Local Machine -> Personal store

### 2. **Certificate Trust**
- Automatically adds certificate to Local Machine Trusted Root
- Exports certificate in multiple formats:
  - `.cer` - For Windows certificate import
  - `.pfx` - Password-protected for cross-platform use
  - Base64 text - For script-based operations

### 3. **WinRM Configuration**
- Stops and restarts WinRM service
- Creates HTTPS listener on port 5986
- Configures authentication methods (Basic, Kerberos, Negotiate)
- Disables unencrypted connections

### 4. **Firewall Configuration**
- Creates inbound rule for TCP port 5986
- Allows ICMP for connectivity testing
- Removes conflicting existing rules

### 5. **Export Files Created**
```
C:\WinRM-Certificates\
├── ComputerName.cer              # Certificate file
├── ComputerName.pfx              # PFX with password
├── ComputerName-base64.txt       # Base64 encoded
├── Import-Certificate-REMOTE.ps1 # Import script for clients
└── Configuration-Summary.txt     # Complete setup summary
```

## Remote Machine Setup

### Step 1: Export Certificate Files

After running the script, certificate files are available at:
- `C:\WinRM-Certificates\` (default)
- Or network path: `\\YOUR-COMPUTER\c$\WinRM-Certificates\`

### Step 2: Import Certificate on Remote Machines

#### Option A: Using the Import Script (Recommended)

```powershell
# From remote machine (run as Administrator)
\\YOUR-COMPUTER\c$\WinRM-Certificates\Import-Certificate-REMOTE.ps1
```

#### Option B: Manual Import

1. **GUI Method:**
   - Double-click the `.cer` file
   - Click "Install Certificate"
   - Select "Local Machine" → Next
   - Select "Place all certificates in the following store"
   - Browse to "Trusted Root Certification Authorities"
   - Click Next → Finish

2. **PowerShell Method:**
   ```powershell
   # Import for current user only
   Import-Certificate -FilePath "C:\Path\To\Certificate.cer" -CertStoreLocation Cert:\CurrentUser\Root

   # Import for all users (requires Admin)
   Import-Certificate -FilePath "C:\Path\To\Certificate.cer" -CertStoreLocation Cert:\LocalMachine\Root
   ```

3. **Command Line Method:**
   ```cmd
   certutil -addstore -f Root "C:\Path\To\Certificate.cer"
   ```

### Step 3: Test Connection

```powershell
# Basic test
Test-WSMan -ComputerName YOUR-COMPUTER -UseSSL

# With credentials
$cred = Get-Credential
Enter-PSSession -ComputerName YOUR-COMPUTER -UseSSL -Credential $cred

# Run remote command
Invoke-Command -ComputerName YOUR-COMPUTER -UseSSL -Credential $cred -ScriptBlock {
    Get-Service WinRM
}
```

## Connection Examples

### PowerShell 5.1 (Windows PowerShell)

```powershell
# Test connection
Test-WSMan -ComputerName server01.domain.com -UseSSL

# Interactive session
Enter-PSSession -ComputerName server01.domain.com -UseSSL -Credential (Get-Credential)

# Run remote commands
Invoke-Command -ComputerName server01.domain.com -UseSSL -Credential $cred -ScriptBlock {
    Get-Process | Select-Object -First 5
}
```

### PowerShell 7+ (PowerShell Core)

```powershell
# Test with skip certificate check (if not imported)
Test-WSMan -ComputerName server01.domain.com -UseSSL -SkipCertificateCheck

# With trusted certificate
Enter-PSSession -ComputerName server01.domain.com -UseSSL -Credential (Get-Credential)
```

### Unattended Scripts

```powershell
# Create credential object
$password = ConvertTo-SecureString "YourPassword" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ("Domain\User", $password)

# Run remote script
Invoke-Command -ComputerName server01.domain.com -UseSSL -Credential $credential -FilePath C:\Script.ps1
```

## Troubleshooting

### Common Issues

#### 1. "Access is Denied"
- **Solution:** Run PowerShell as Administrator
- **Command:** `Start-Process powershell -Verb RunAs`

#### 2. "Cannot Connect to Destination"
- **Check:** WinRM service status
- **Command:** `Get-Service WinRM`
- **Fix:** `Start-Service WinRM`

#### 3. "Certificate Validation Failed"
- **Check:** Certificate is in Trusted Root store
- **Command:** `certlm.msc` (open Certificate Manager)
- **Fix:** Import certificate to Trusted Root Certification Authorities

#### 4. "Firewall Blocking Connection"
- **Check:** Port 5986 is open
- **Command:** `Test-NetConnection -ComputerName TARGET -Port 5986`
- **Fix:** Ensure firewall rule exists: `netsh advfirewall firewall show rule name="WinRM HTTPS"`

#### 5. "The SSL Certificate contains a CN that does not match"
- **Cause:** Connecting with wrong hostname
- **Fix:** Use FQDN or computer name exactly as in certificate SAN
- **Alternative:** Add IP address to certificate SAN and connect by IP

### Diagnostic Commands

```powershell
# Check WinRM service
Get-Service WinRM

# Check listeners
winrm enumerate winrm/config/listener

# Check port
netstat -an | findstr :5986

# Test connectivity
Test-NetConnection -ComputerName TARGET -Port 5986

# Check certificate details
Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -match "CN=" } | Format-List *

# Verify firewall rule
Get-NetFirewallRule -Name "WinRM HTTPS*" | Format-Table Name, Enabled, Action
```

### Reset WinRM Configuration

If configuration becomes corrupted:

```powershell
# Complete reset
winrm delete winrm/config/listener?Address=*+Transport=HTTPS
winrm delete winrm/config/listener?Address=*+Transport=HTTP
Stop-Service WinRM
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN" -Recurse -Force
Start-Service WinRM
winrm quickconfig -transport:https -force
```

## Security Considerations

### 1. **Certificate Security**
- Default PFX password: `WinRM-Secure-P@ssw0rd!`
- **Recommendation:** Change password using `-PfxPassword` parameter
- Certificate validity: 3 years (configurable in script)

### 2. **Authentication**
- Basic authentication enabled (for cross-domain compatibility)
- Kerberos and Negotiate authentication enabled
- Unencrypted connections disabled

### 3. **Network Security**
- Port 5986 open in firewall (restrict with `-RemoteIP` parameter if needed)
- Consider IP restrictions for production environments
- Use VPN for internet-facing servers

### 4. **Best Practices**
- Use strong PFX passwords
- Restrict certificate access to authorized users
- Monitor WinRM logs: `Event Viewer → Applications and Services Logs → Microsoft → Windows → Windows Remote Management`
- Regularly update and renew certificates

## Advanced Configuration

### Custom SAN Entries

To add additional SAN entries (IP addresses, alternate names), modify line 78-80 in the script:

```powershell
$certParams = @{
    Subject           = "CN=$fqdn"
    DnsName           = @($fqdn, $computerName, "localhost", "additional.alias.com")
    # ... other parameters
}
```

### Multiple IP Addresses

```powershell
# Get all IP addresses
$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -ne '127.0.0.1' } |
    Select-Object -ExpandProperty IPAddress

# Add to certificate (requires certreq method, not shown in current script)
```

### Group Policy Integration

For domain environments, consider using Group Policy for:
- Certificate auto-enrollment
- WinRM configuration deployment
- Firewall rule management

## Script Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ExportPath` | Directory for certificate exports | `C:\WinRM-Certificates` |
| `PfxPassword` | Password for PFX file export | `WinRM-Secure-P@ssw0rd!` |

## Files Generated

| File | Purpose | Usage |
|------|---------|-------|
| `ComputerName.cer` | Certificate file | Windows certificate import |
| `ComputerName.pfx` | Password-protected certificate | Cross-platform applications |
| `ComputerName-base64.txt` | Base64 encoded certificate | Scripts, automation |
| `Import-Certificate-REMOTE.ps1` | Import script | Remote machine setup |
| `Configuration-Summary.txt` | Setup summary | Documentation, reference |

## Support

### Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| "Access is denied" | Insufficient privileges | Run as Administrator |
| "Certificate not trusted" | Certificate not in Trusted Root | Import to Trusted Root store |
| "Cannot connect" | Firewall blocking, service stopped | Check service and firewall |
| "CN does not match" | Wrong hostname used | Use FQDN or name from certificate SAN |

### Logs and Monitoring

- **WinRM Operational Logs:** `Event Viewer → Applications and Services Logs → Microsoft → Windows → Windows Remote Management → Operational`
- **Firewall Logs:** `Event Viewer → Windows Logs → Security`
- **Service Logs:** `Event Viewer → Windows Logs → System`

## Version History

- **v2.0** (Current): Production-ready with remote trust support
  - Multiple certificate export formats
  - Remote import script
  - Comprehensive documentation
  - Enhanced troubleshooting

- **v1.0**: Initial release
  - Basic WinRM HTTPS setup
  - Self-signed certificate creation
  - Firewall configuration

## License

This script is provided as-is for educational and operational purposes. Use at your own risk in production environments.

## Contributing

Issues and pull requests can be submitted via the repository. Please include detailed descriptions and error messages.

---

**Note:** This script configures self-signed certificates suitable for internal/testing environments. For production/public-facing servers, consider using certificates from a trusted Certificate Authority (CA).
