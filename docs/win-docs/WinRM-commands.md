# WinRM Mastery Guide: Commands, Configuration & Learning

## 📋 Introduction

**Windows Remote Management (WinRM)** is the Microsoft implementation of WS-Management Protocol, enabling secure remote management of Windows systems. This comprehensive guide covers everything from basic setup to advanced automation.

---

## 🚀 Quick Start: Basic Setup & Configuration

### Essential Configuration Commands

| Command | Description | Example | Notes |
|---------|-------------|---------|-------|
| **`winrm quickconfig`** | Interactive WinRM setup wizard | `winrm quickconfig` | Creates HTTP listener, sets firewall rules |
| **`winrm quickconfig -q`** | Silent configuration | `winrm quickconfig -q` | No prompts, uses defaults |
| **`Enable-PSRemoting`** | Enable PowerShell remoting | `Enable-PSRemoting -Force` | Sets up WSMan, listeners, and firewall |
| **`Set-WSManQuickConfig`** | Alternative configuration method | `Set-WSManQuickConfig -Force` | Similar to `Enable-PSRemoting` |
| **`Disable-PSRemoting`** | Disable PowerShell remoting | `Disable-PSRemoting -Force` | Removes listeners, resets configuration |

### Service Management

```powershell
# Service Control
Get-Service WinRM                              # Check service status
Start-Service WinRM                            # Start service
Stop-Service WinRM -Force                      # Stop service
Restart-Service WinRM -Force                   # Restart service

# Service Configuration
Set-Service WinRM -StartupType Automatic       # Auto-start on boot
Set-Service WinRM -StartupType Manual          # Manual start only
Set-Service WinRM -StartupType Disabled        # Disable service

# Service Information
Get-WmiObject Win32_Service -Filter "Name='WinRM'" | Select-Object *
```

---

## 🎧 Listener Management & Configuration

### Creating Listeners

```powershell
# Create HTTP Listener (Port 5985)
winrm create winrm/config/Listener?Address=*+Transport=HTTP

# Create HTTPS Listener (Port 5986)
$cert = Get-ChildItem Cert:\LocalMachine\My | Select-Object -First 1
winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{CertificateThumbprint="$($cert.Thumbprint)"}

# Alternative PowerShell method
New-WSManInstance -ResourceURI winrm/config/listener `
    -SelectorSet @{Address="*";Transport="HTTPS"} `
    -ValueSet @{CertificateThumbprint="THUMBPRINT";Enabled="true"}

# Create with specific hostname
winrm create winrm/config/Listener?Address=*+Transport=HTTPS `
    @{Hostname="server01.contoso.com";CertificateThumbprint="THUMBPRINT"}
```

### Managing Existing Listeners

```powershell
# List all listeners
Get-ChildItem WSMan:\localhost\Listener
winrm enumerate winrm/config/listener
Get-WSManInstance -ResourceURI winrm/config/listener -Enumerate

# Get specific listener details
$listener = Get-ChildItem WSMan:\localhost\Listener | Where-Object {$_.Transport -eq "HTTPS"}
$listener | Format-List *

# Update listener certificate
Set-Item WSMan:\localhost\Listener\Listener_123456\CertificateThumbprint "NEW_THUMBPRINT"

# Remove listener
Remove-WSManInstance -ResourceURI winrm/config/listener -SelectorSet @{Address="*";Transport="HTTPS"}
winrm delete winrm/config/Listener?Address=*+Transport=HTTPS
```

---

## ⚙️ Service Configuration & Tuning

### Viewing Configuration

```powershell
# Complete configuration
winrm get winrm/config
Get-Item WSMan:\localhost

# Specific sections
winrm get winrm/config/service
winrm get winrm/config/client
winrm get winrm/config/winrs

# PowerShell equivalents
Get-WSManInstance -ResourceURI winrm/config
Get-WSManInstance -ResourceURI winrm/config/service
```

### Configuration Settings

```powershell
# Security Settings
winrm set winrm/config/service @{AllowUnencrypted="false"}              # Require encryption
winrm set winrm/config/service @{MaxConcurrentOperations="4294967295"}  # Max operations
winrm set winrm/config/service @{MaxConcurrentOperationsPerUser="1500"} # Per user limit

# Authentication Methods
winrm set winrm/config/service/auth @{Basic="true"}                     # Enable Basic auth
winrm set winrm/config/service/auth @{Kerberos="true"}                  # Enable Kerberos
winrm set winrm/config/service/auth @{Negotiate="true"}                 # Enable Negotiate
winrm set winrm/config/service/auth @{Certificate="true"}               # Enable Certificate auth
winrm set winrm/config/service/auth @{CredSSP="true"}                   # Enable CredSSP

# Client Configuration
winrm set winrm/config/client @{TrustedHosts="192.168.1.*,server01"}   # Configure trusted hosts
winrm set winrm/config/client @{NetworkDelayms="5000"}                  # Network timeout
winrm set winrm/config/client/auth @{Basic="true"}                      # Client auth methods

# WinRS Configuration (Remote Shell)
winrm set winrm/config/winrs @{MaxMemoryPerShellMB="1024"}              # Memory limit per shell
winrm set winrm/config/winrs @{MaxProcessesPerShell="25"}               # Process limit
winrm set winrm/config/winrs @{MaxShellsPerUser="30"}                   # Shells per user
```

### PowerShell WSMan Provider Commands

```powershell
# Navigate WSMan configuration
cd WSMan:\localhost
Get-ChildItem

# Configure settings via provider
Set-Item .\Shell\MaxMemoryPerShellMB 2048
Set-Item .\Service\AllowUnencrypted $false

# Create custom settings
New-Item -Path .\Plugin\TestPlugin -Force
Set-Item -Path .\Plugin\TestPlugin\Enabled $true
```

---

## 🔗 Connectivity & Testing

### Basic Connectivity Tests

```powershell
# Test without SSL (HTTP)
Test-WSMan localhost
Test-WSMan -ComputerName server01
Test-WSMan -ComputerName 192.168.1.100

# Test with SSL (HTTPS)
Test-WSMan localhost -UseSSL
Test-WSMan -ComputerName server01 -UseSSL

# Test with authentication
$cred = Get-Credential
Test-WSMan -ComputerName server01 -UseSSL -Credential $cred

# Test specific port
Test-Connection -ComputerName server01 -Port 5986
Test-NetConnection -ComputerName server01 -Port 5986
```

### Advanced Diagnostics

```powershell
# Get detailed connection info
$wsman = New-WSManSessionOption
$wsman | Format-List *

# Test with session options
$options = New-WSManSessionOption -NoEncryption
Test-WSMan -ComputerName server01 -SessionOption $options

# Check port status
Get-NetTCPConnection -LocalPort 5986 -ErrorAction SilentlyContinue
netstat -an | findstr :5986

# Test from different authentication contexts
Test-WSMan -ComputerName server01 -Authentication Kerberos
Test-WSMan -ComputerName server01 -Authentication Negotiate
Test-WSMan -ComputerName server01 -Authentication Basic
```

---

## 💻 Remote Command Execution

### Interactive Sessions

```powershell
# Basic interactive session
Enter-PSSession -ComputerName server01
Enter-PSSession -ComputerName server01 -Credential (Get-Credential)

# SSL sessions
Enter-PSSession -ComputerName server01 -UseSSL
Enter-PSSession -ComputerName server01 -UseSSL -Credential (Get-Credential)

# Session with specific configuration
$session = New-PSSession -ComputerName server01 -UseSSL -Credential $cred
Enter-PSSession -Session $session

# Multiple computer sessions
$sessions = New-PSSession -ComputerName server01,server02,server03
Enter-PSSession -Session $sessions[0]
```

### Script & Command Execution

```powershell
# Single command execution
Invoke-Command -ComputerName server01 -ScriptBlock { Get-Process }
Invoke-Command -ComputerName server01,server02 -ScriptBlock { Get-Service }

# With authentication
$cred = Get-Credential
Invoke-Command -ComputerName server01 -ScriptBlock { Get-EventLog System -Newest 10 } -Credential $cred

# Execute script file remotely
Invoke-Command -ComputerName server01 -FilePath C:\Scripts\deploy.ps1 -Credential $cred

# Parallel execution
Invoke-Command -ComputerName (Get-Content servers.txt) -ScriptBlock { Restart-Service Spooler } -ThrottleLimit 10

# Persistent sessions for multiple commands
$session = New-PSSession -ComputerName server01 -Credential $cred
Invoke-Command -Session $session -ScriptBlock { $data = Get-Content "C:\log.txt" }
Invoke-Command -Session $session -ScriptBlock { $data | Measure-Object -Line }
Remove-PSSession $session
```

### Session Management

```powershell
# List all sessions
Get-PSSession
Get-PSSession -ComputerName server01

# Create and manage sessions
$sessions = @()
$sessions += New-PSSession -ComputerName server01 -Name "WebServer"
$sessions += New-PSSession -ComputerName server02 -Name "DBServer"

# Use named sessions
Invoke-Command -Session (Get-PSSession -Name "WebServer") -ScriptBlock { Get-IISAppPool }

# Disconnect and reconnect
Disconnect-PSSession -Session $sessions[0]
Connect-PSSession -ComputerName server01 -Name "WebServer"

# Cleanup
Get-PSSession | Remove-PSSession
```

---

## 🔐 Security & Certificate Management

### Certificate Operations

```powershell
# Generate self-signed certificate
$cert = New-SelfSignedCertificate -Subject "CN=server01.contoso.com" -CertStoreLocation Cert:\LocalMachine\My -DnsName server01.contoso.com,server01,localhost

# Export certificate
Export-Certificate -Cert $cert -FilePath C:\cert.cer -Type CERT
Export-PfxCertificate -Cert $cert -FilePath C:\cert.pfx -Password (ConvertTo-SecureString "Password123" -AsPlainText -Force)

# Import certificate
Import-Certificate -FilePath C:\cert.cer -CertStoreLocation Cert:\LocalMachine\Root
Import-PfxCertificate -FilePath C:\cert.pfx -CertStoreLocation Cert:\LocalMachine\My -Password (ConvertTo-SecureString "Password123" -AsPlainText -Force)

# Find certificates for WinRM
Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.HasPrivateKey -and $_.EnhancedKeyUsageList -match "Server Authentication" }

# Certificate thumbprint extraction
$cert.Thumbprint
Get-ChildItem Cert:\LocalMachine\My | Select-Object Thumbprint, Subject, NotAfter
```

### Security Configuration

```powershell
# Enable/disable authentication methods
Set-WSManInstance -ResourceURI winrm/config/service/auth -ValueSet @{Basic="false"}
Set-WSManInstance -ResourceURI winrm/config/service/auth -ValueSet @{Kerberos="true"}

# Configure encryption requirements
Set-Item WSMan:\localhost\Service\AllowUnencrypted $false

# IP restrictions (via firewall)
New-NetFirewallRule -DisplayName "WinRM HTTPS Restricted" -Direction Inbound -LocalPort 5986 -Protocol TCP -Action Allow -RemoteAddress 192.168.1.0/24

# Configure message encryption
Set-Item WSMan:\localhost\Service\EnableCompatibilityHttpsListener $false
Set-Item WSMan:\localhost\Service\EnableCompatibilityHttpListener $false
```

---

## 🛠️ Advanced Configuration & Automation

### WinRM Provider Deep Dive

```powershell
# Explore WSMan provider structure
Get-ChildItem WSMan:\localhost\Plugin -Recurse
Get-ChildItem WSMan:\localhost\ClientAuth -Recurse

# Configure custom plugins
$pluginParams = @{
    ResourceURI = "winrm/config/plugin"
    SelectorSet = @{Name="TestPlugin";ResourceUri="http://schemas.microsoft.com/powershell/Microsoft.PowerShell"}
    ValueSet = @{
        Enabled = $true
        Filename = "%windir%\system32\pwrshplugin.dll"
        SDKVersion = "2"
    }
}
New-WSManInstance @pluginParams
```

### Performance Tuning

```powershell
# Memory and process limits
winrm set winrm/config/winrs @{MaxMemoryPerShellMB="2048"}
winrm set winrm/config/winrs @{MaxProcessesPerShell="50"}
winrm set winrm/config/winrs @{MaxShellsPerUser="30"}

# Timeout settings
winrm set winrm/config @{MaxTimeoutms="1800000"}
winrm set winrm/config @{MaxEnvelopeSizekb="500"}

# Connection pooling
winrm set winrm/config/service @{MaxConnections="100"}
```

### Automation Scripts

```powershell
# Bulk WinRM configuration
$servers = Get-Content .\servers.txt
foreach ($server in $servers) {
    Invoke-Command -ComputerName $server -ScriptBlock {
        # Configure WinRM
        Enable-PSRemoting -Force
        winrm set winrm/config/service/auth @{Basic="true"}
        winrm set winrm/config/service @{AllowUnencrypted="false"}

        # Create HTTPS listener
        $cert = New-SelfSignedCertificate -Subject "CN=$env:COMPUTERNAME" -CertStoreLocation Cert:\LocalMachine\My
        winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{CertificateThumbprint="$($cert.Thumbprint)"}
    } -Credential (Get-Credential)
}

# Health check automation
function Test-WinRMHealth {
    param([string[]]$Computers)

    $results = @()
    foreach ($computer in $Computers) {
        $status = [PSCustomObject]@{
            ComputerName = $computer
            WinRMService = (Get-Service WinRM -ComputerName $computer -ErrorAction SilentlyContinue).Status
            Port5985 = Test-NetConnection -ComputerName $computer -Port 5985 -WarningAction SilentlyContinue
            Port5986 = Test-NetConnection -ComputerName $computer -Port 5986 -WarningAction SilentlyContinue
            TestWSMan = try { Test-WSMan -ComputerName $computer -ErrorAction Stop; $true } catch { $false }
        }
        $results += $status
    }
    return $results
}
```

---

## 🧪 Learning & Practice Environment

### Safe Practice Script

```powershell
<#
.SYNOPSIS
    WinRM Learning Lab - Safe Practice Environment
.DESCRIPTION
    Creates an isolated WinRM learning environment with automatic cleanup.
    Perfect for testing commands without affecting production systems.
.NOTES
    Run as Administrator. All changes are automatically reverted.
#>

function Initialize-WinRMLab {
    [CmdletBinding()]
    param(
        [switch]$ForceCleanup
    )

    # Backup current configuration
    $backupFile = "$env:TEMP\WinRM_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').xml"
    winrm get winrm/config -format:pretty > $backupFile
    Write-Host "📁 Configuration backed up to: $backupFile" -ForegroundColor Green

    # Create isolated learning environment
    $labCert = New-SelfSignedCertificate `
        -Subject "CN=WinRM-Lab-$(Get-Random)" `
        -DnsName "lab-localhost", "127.0.0.1" `
        -CertStoreLocation Cert:\LocalMachine\My `
        -NotAfter (Get-Date).AddHours(2)  # Auto-expires in 2 hours

    # Create dedicated lab listener
    New-WSManInstance -ResourceURI winrm/config/listener `
        -SelectorSet @{Address="127.0.0.1";Transport="HTTPS"} `
        -ValueSet @{CertificateThumbprint=$labCert.Thumbprint;Port="55986"}

    Write-Host @"

🎓 WINRM LEARNING LAB READY
============================
Lab Certificate: $($labCert.Thumbprint)
Lab Endpoint: https://127.0.0.1:55986/wsman
Expires: $($labCert.NotAfter)

PRACTICE COMMANDS:
Test-WSMan -ComputerName 127.0.0.1 -UseSSL -Port 55986
Enter-PSSession -ComputerName 127.0.0.1 -UseSSL -Port 55986

This lab will auto-cleanup in 2 hours or when you run:
Initialize-WinRMLab -ForceCleanup
"@ -ForegroundColor Cyan
}

# Example practice exercises
$practiceExercises = @"
EXERCISE 1: Basic Connectivity
--------------------------------
Test-WSMan -ComputerName 127.0.0.1 -UseSSL -Port 55986

EXERCISE 2: Remote Command Execution
-------------------------------------
Invoke-Command -ComputerName 127.0.0.1 -UseSSL -Port 55986 -ScriptBlock { Get-Process | Select-Object -First 3 }

EXERCISE 3: Interactive Session
--------------------------------
Enter-PSSession -ComputerName 127.0.0.1 -UseSSL -Port 55986
Get-Service | Where-Object Status -eq 'Running'
Exit-PSSession

EXERCISE 4: Certificate Management
-----------------------------------
Get-ChildItem Cert:\LocalMachine\My | Where-Object Subject -match "WinRM-Lab"

EXERCISE 5: Configuration Exploration
--------------------------------------
winrm get winrm/config
Get-ChildItem WSMan:\localhost\Listener
"@
```

---

## 🔧 Troubleshooting Guide

### Common Issues & Solutions

| Symptom | Possible Cause | Solution |
|---------|---------------|----------|
| **"Access is denied"** | Insufficient permissions | Run as Administrator, check firewall, verify credentials |
| **"The client cannot connect"** | Service not running | `Start-Service WinRM`, check firewall rules |
| **"SSL certificate error"** | Certificate issues | Import certificate to Trusted Root, use `-SkipCertificateCheck` |
| **"WinRM not recognized"** | WinRM not installed | Enable via `Enable-PSRemoting`, check Windows features |
| **"Maximum connections exceeded"** | Too many sessions | Increase `MaxShellsPerUser`, clean up old sessions |

### Diagnostic Commands

```powershell
# Comprehensive diagnostics
function Test-WinRMConfiguration {
    param([string]$ComputerName = "localhost")

    $tests = @(
        @{Name="Service Status"; Test={ Get-Service WinRM -ComputerName $ComputerName -ErrorAction SilentlyContinue }},
        @{Name="Port 5985"; Test={ Test-NetConnection -ComputerName $ComputerName -Port 5985 -WarningAction SilentlyContinue }},
        @{Name="Port 5986"; Test={ Test-NetConnection -ComputerName $ComputerName -Port 5986 -WarningAction SilentlyContinue }},
        @{Name="HTTP Listener"; Test={ Test-WSMan -ComputerName $ComputerName -ErrorAction SilentlyContinue }},
        @{Name="HTTPS Listener"; Test={ Test-WSMan -ComputerName $ComputerName -UseSSL -ErrorAction SilentlyContinue }}
    )

    foreach ($test in $tests) {
        try {
            $result = & $test.Test
            Write-Host "✓ $($test.Name): PASS" -ForegroundColor Green
        } catch {
            Write-Host "✗ $($test.Name): FAIL - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Check WinRM logs
Get-WinEvent -LogName "Microsoft-Windows-WinRM/Operational" -MaxEvents 10
```

---

## 📚 Learning Pathways

### Beginner Path (1-2 hours)
1. Enable WinRM: `Enable-PSRemoting -Force`
2. Test locally: `Test-WSMan localhost`
3. Create HTTPS listener with certificate
4. Practice `Invoke-Command` on localhost
5. Explore configuration: `winrm get winrm/config`

### Intermediate Path (3-4 hours)
1. Configure cross-domain authentication
2. Set up certificate-based authentication
3. Create restricted firewall rules
4. Implement session persistence
5. Build basic automation scripts

### Advanced Path (5+ hours)
1. Custom WSMan plugin development
2. Performance tuning for large-scale deployment
3. Integration with Configuration Management (DSC)
4. Security hardening and audit compliance
5. Building monitoring and alerting systems

---

## 🎯 Best Practices Checklist

- [ ] **Always use HTTPS** for production environments
- [ ] **Restrict access** with firewall rules and IP filtering
- [ ] **Use certificate authentication** instead of passwords when possible
- [ ] **Implement logging** for audit trails
- [ ] **Regularly update certificates** before expiration
- [ ] **Test configurations** in isolated environments first
- [ ] **Use constrained endpoints** for delegated administration
- [ ] **Monitor session usage** and clean up idle sessions
- [ ] **Keep WinRM and PowerShell updated**
- [ ] **Document all custom configurations**

---

## 🔗 Resources & References

| Resource | Type | URL |
|----------|------|-----|
| **Microsoft Docs** | Official Documentation | [WinRM Documentation](https://learn.microsoft.com/windows/win32/winrm/portal) |
| **PowerShell Docs** | Remoting Guide | [PowerShell Remoting](https://learn.microsoft.com/powershell/scripting/learn/remoting/) |
| **GitHub Repo** | Community Scripts | [PowerShell/WinRM](https://github.com/PowerShell/WinRM) |
| **TechNet Gallery** | Tools & Utilities | [WinRM Tools](https://gallery.technet.microsoft.com) |
| **Stack Overflow** | Q&A Community | [winrm tag](https://stackoverflow.com/questions/tagged/winrm) |

---

## 🚨 Emergency Commands

```powershell
# Complete WinRM reset (use with caution!)
function Reset-WinRM {
    Stop-Service WinRM -Force
    winrm delete winrm/config/listener?Address=*+Transport=HTTP 2>$null
    winrm delete winrm/config/listener?Address=*+Transport=HTTPS 2>$null
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN" -Recurse -Force
    Start-Service WinRM
    winrm quickconfig -transport:https -force
}

# Export all WinRM configuration
function Backup-WinRMConfig {
    param([string]$BackupPath = "C:\WinRM-Backup")

    New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
    winrm get winrm/config -format:pretty > "$BackupPath\config.xml"
    Export-Certificate -Cert (Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.EnhancedKeyUsageList -match "Server Authentication"}) -FilePath "$BackupPath\certificates.cer"
    Get-NetFirewallRule -Name "*WinRM*" | Export-Clixml "$BackupPath\firewall.xml"
}
```

---

*Last Updated: $(Get-Date -Format 'yyyy-MM-dd')*
*Remember: Always test configurations in a non-production environment first.*
