[Introduction — Jinja Documentation (3.2.x)](https://jinja.palletsprojects.com/en/latest/intro/#installation)

### Step-by-Step Solution

```powershell
# 1. Find the certificate with the thumbprint from earlier
$thumbprint = "F1F9AECEED865FFA7214E634AF8792C35374168E"
$cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object Thumbprint -eq $thumbprint

# 2. Export the certificate
$cert | Export-Certificate -FilePath .\winrm_cert.cer -Type CERT

# 3. Import certificate to Trusted Root store
Import-Certificate -FilePath .\winrm_cert.cer -CertStoreLocation Cert:\LocalMachine\Root

# 4. Reconfigure WinRM HTTPS listener
winrm delete winrm/config/Listener?Address=*+Transport=HTTPS -Force
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"$env:COMPUTERNAME`"; CertificateThumbprint=`"$thumbprint`"}"

# 5. Restart WinRM service
Restart-Service WinRM

# 6. Test again
Test-WSMan -UseSSL -ErrorAction Stop
```

### Alternative Solution (Bypass Certificate Validation for Testing)

```powershell
# Add registry entry to disable certificate validation (temporary fix)
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" `
    -Name "WinHttpSkipVerifyServers" -Value "localhost" -PropertyType String -Force

# Test connection again
Test-WSMan -UseSSL
```

### If Still Failing - Recreate Certificate

```powershell
# 1. Remove existing certificate
Remove-Item -Path "Cert:\LocalMachine\My\$thumbprint" -DeleteKey -Force

# 2. Create new certificate
$newCert = New-SelfSignedCertificate -DnsName $env:COMPUTERNAME, "localhost" `
    -CertStoreLocation "Cert:\LocalMachine\My" `
    -FriendlyName "WinRM HTTPS Certificate" `
    -KeyUsage DigitalSignature, KeyEncipherment `
    -KeySpec KeyExchange `
    -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider"

# 3. Import to Trusted Root
Export-Certificate -Cert $newCert -FilePath .\new_cert.cer | Out-Null
Import-Certificate -FilePath .\new_cert.cer -CertStoreLocation Cert:\LocalMachine\Root

# 4. Reconfigure listener
winrm delete winrm/config/Listener?Address=*+Transport=HTTPS -Force
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"$env:COMPUTERNAME`"; CertificateThumbprint=`"$newCert.Thumbprint`"}"

# 5. Test again
Test-WSMan -UseSSL
```

### Verify Certificate Configuration

```powershell
# Check listener binding
winrm enumerate winrm/config/listener

# Check certificate details
$newCert | Format-List Subject, Thumbprint, NotBefore, NotAfter, SerialNumber

# Check certificate chain
Test-Certificate -Cert $newCert -Verbose
```

### For Ansible Connections

Add this to your inventory file to bypass certificate validation (temporary measure):

```ini
[windows:vars]
ansible_winrm_server_cert_validation=ignore
```

### Permanent Solution (For Production)

1. Obtain a valid certificate from a trusted Certificate Authority

2. Import it to the computer's certificate store

3. Bind it to WinRM:
   
   ```powershell
   winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"your-hostname`"; CertificateThumbprint=`"CA_CERT_THUMBPRINT`"}"
   ```
   
   =================

### Fix for SSL Certificate Error

```powershell
# 1. Remove existing problematic certificate and listener
winrm delete winrm/config/Listener?Address=*+Transport=HTTPS -Force
$thumbprint = "F1F9AECEED865FFA7214E634AF8792C35374168E"
Remove-Item -Path "Cert:\LocalMachine\My\$thumbprint" -DeleteKey -Force

# 2. Create a new self-signed certificate with proper properties
$cert = New-SelfSignedCertificate `
    -DnsName $env:COMPUTERNAME `
    -CertStoreLocation "Cert:\LocalMachine\My" `
    -FriendlyName "Ansible WinRM HTTPS" `
    -KeySpec KeyExchange `
    -KeyLength 2048 `
    -NotAfter (Get-Date).AddYears(5) `
    -KeyExportPolicy Exportable `
    -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider"

# 3. Configure HTTPS listener with new certificate
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"$env:COMPUTERNAME`"; CertificateThumbprint=`"$($cert.Thumbprint)`"}"

# 4. Verify the new listener configuration
winrm enumerate winrm/config/listener | Select-String "Transport" -Context 0,10
```

### Critical Additional Steps

```powershell
# 5. Enable strong cryptography for .NET Framework (fixes SSL library errors)
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value 1 -Type DWord
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value 1 -Type DWord

# 6. Reconfigure authentication
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="false"}'  # Force HTTPS only

# 7. Restart WinRM service
Restart-Service WinRM -Force
```

### Test the Configuration

```powershell
# Test HTTP connection (should fail since we disabled unencrypted traffic)
Test-WSMan -ErrorAction SilentlyContinue

# Test HTTPS connection (should succeed)
Test-WSMan -UseSSL -Authentication Default
```

### Verify Certificate Validity

```powershell
# Check certificate details
Get-ChildItem Cert:\LocalMachine\My\$($cert.Thumbprint) | Format-List *

# Check certificate chain
Test-Certificate -Cert $cert -ErrorAction SilentlyContinue
```

### If Still Failing (Last Resort)

```powershell
# Recreate certificate with all required extensions
$cert = New-SelfSignedCertificate `
    -Subject "CN=$env:COMPUTERNAME" `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.1") `
    -KeyUsage DigitalSignature,KeyEncipherment `
    -KeyAlgorithm RSA `
    -KeyLength 2048 `
    -NotAfter (Get-Date).AddYears(5) `
    -CertStoreLocation "Cert:\LocalMachine\My"

# Recreate listener
winrm delete winrm/config/Listener?Address=*+Transport=HTTPS -Force
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"$env:COMPUTERNAME`"; CertificateThumbprint=`"$($cert.Thumbprint)`"}"

# Add certificate to trusted root
Export-Certificate -Cert $cert -FilePath .\winrm.cer | Out-Null
Import-Certificate -FilePath .\winrm.cer -CertStoreLocation Cert:\LocalMachine\Root
```

### Ansible Configuration Fix

Add this to your inventory file:

```ini
[windows:vars]
ansible_winrm_server_cert_validation=ignore  # Temporary for testing
ansible_winrm_transport=basic
```

After applying these fixes, test with:

```powershell
Test-WSMan -UseSSL -Authentication Basic
```
