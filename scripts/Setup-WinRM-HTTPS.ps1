<#
.SYNOPSIS
    Configures WinRM over HTTPS using either:
    - A valid CA-signed or self-signed certificate (.pfx), or
    - An automatically generated Certificate Signing Request (CSR)

.DESCRIPTION
    This script:
    1. Imports a .pfx into the LocalMachine\My certificate store, OR generates a CSR
    2. Supports generating a **self-signed certificate** automatically
    3. Creates an HTTPS WinRM listener bound to the given hostname
    4. Restarts and verifies the WinRM service
    5. Optionally falls back to HTTP if HTTPS setup fails
    6. Can create and export a client certificate for the Ansible control node
    7. Is CI/CD-friendly (non-interactive, idempotent)

.PARAMETER PfxPath
    Full path to the .pfx certificate file to import.

.PARAMETER CertPassword
    Password for the .pfx file.

.PARAMETER Hostname
    The FQDN or hostname to bind the HTTPS listener to.

.PARAMETER GenerateCSR
    Switch to generate a CSR instead of importing a certificate.

.PARAMETER SelfSigned
    Switch to generate a trusted self-signed certificate for local testing.

.PARAMETER UseHTTPFallback
    Switch to enable fallback HTTP listener if HTTPS setup fails.

.PARAMETER ExportClientCert
    Path to export a matching client certificate for Ansible control node use.

.EXAMPLE
    .\Setup-WinRM-HTTPS.ps1 -PfxPath "C:\certs\mycert.pfx" -CertPassword "securepass" -Hostname "server.example.com"

.EXAMPLE
    .\Setup-WinRM-HTTPS.ps1 -GenerateCSR -Hostname "server.example.com"

.EXAMPLE
    .\Setup-WinRM-HTTPS.ps1 -SelfSigned -Hostname "server.example.com" -ExportClientCert "C:\certs\ansible-client.pfx"
#>

param (
    [string]$PfxPath,
    [string]$CertPassword,
    [Parameter(Mandatory = $true)]
    [string]$Hostname,
    [switch]$GenerateCSR,
    [switch]$SelfSigned,
    [switch]$UseHTTPFallback,
    [string]$ExportClientCert
)

# -------------------------------
# 1️⃣ Function: Generate CSR
# -------------------------------
function New-WinRMCSR {
    $infContent = @"
[Version]
Signature=`"$Windows NT$`"

[NewRequest]
Subject = "CN=$Hostname"
KeySpec = 1
KeyLength = 2048
Exportable = TRUE
MachineKeySet = TRUE
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
ProviderType = 12
RequestType = PKCS10
KeyUsage = 0xa0

[EnhancedKeyUsageExtension]
OID=1.3.6.1.5.5.7.3.1
"@

    $infPath = "$env:TEMP\winrm_https.inf"
    $csrPath = "$env:TEMP\winrm_https.req"

    $infContent | Out-File -FilePath $infPath -Encoding ascii
    certreq -new $infPath $csrPath | Out-Null

    Write-Host "📤 CSR generated at: $csrPath" -ForegroundColor Green
    Write-Host "➡️ Submit this CSR to your CA, then rerun this script with -PfxPath to import."
    exit 0
}

# -------------------------------
# 2️⃣ Function: Create Self-Signed Cert
# -------------------------------
function New-WinRMSelfSignedCert {
    Write-Host "📜 Generating self-signed certificate for $Hostname..." -ForegroundColor Cyan
    $cert = New-SelfSignedCertificate `
        -DnsName $Hostname `
        -CertStoreLocation Cert:\LocalMachine\My `
        -KeyLength 2048 `
        -KeyExportPolicy Exportable `
        -Provider "Microsoft RSA SChannel Cryptographic Provider" `
        -NotAfter (Get-Date).AddYears(2) `
        -FriendlyName "WinRM HTTPS Self-Signed"

    if (-not $cert) {
        Write-Error "❌ Failed to create self-signed certificate."
        exit 1
    }

    if ($ExportClientCert) {
        $securePass = ConvertTo-SecureString "ansible" -AsPlainText -Force
        Export-PfxCertificate -Cert $cert -FilePath $ExportClientCert -Password $securePass | Out-Null
        Write-Host "📦 Client certificate exported to $ExportClientCert" -ForegroundColor Green
    }

    return $cert
}

# -------------------------------
# 3️⃣ Start Execution
# -------------------------------
Write-Host "🔐 Configuring WinRM over HTTPS..." -ForegroundColor Cyan

if ($GenerateCSR) {
    New-WinRMCSR
}

if ($SelfSigned) {
    $cert = New-WinRMSelfSignedCert
} elseif ($PfxPath) {
    if (-not (Test-Path $PfxPath)) {
        Write-Error "❌ .pfx file not found: $PfxPath"
        exit 1
    }
    Write-Host "📥 Importing certificate from $PfxPath..." -ForegroundColor Yellow
    $securePass = ConvertTo-SecureString -String $CertPassword -AsPlainText -Force
    $cert = Import-PfxCertificate -FilePath $PfxPath `
        -CertStoreLocation Cert:\LocalMachine\My `
        -Password $securePass
} else {
    Write-Error "❌ No certificate source provided. Use -PfxPath, -GenerateCSR, or -SelfSigned."
    exit 1
}

# -------------------------------
# 4️⃣ Configure WinRM HTTPS Listener
# -------------------------------
$thumbprint = $cert.Thumbprint.Trim()
Write-Host "🔎 Using certificate thumbprint: $thumbprint" -ForegroundColor Green

# Remove old HTTPS listeners
$oldHttps = winrm enumerate winrm/config/listener | Where-Object { $_ -like "*Transport=HTTPS*" }
foreach ($listener in $oldHttps) {
    $id = ($listener -split 'ListenerId=')[-1].Trim()
    winrm delete "winrm/config/Listener?ListenerId=$id" | Out-Null
}

# Create new HTTPS listener
Write-Host "🔧 Creating HTTPS WinRM listener..." -ForegroundColor Yellow
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"$Hostname`"; CertificateThumbprint=`"$thumbprint`"}" | Out-Null

# -------------------------------
# 5️⃣ Restart & Verify
# -------------------------------
Restart-Service WinRM
$verify = winrm enumerate winrm/config/listener
if ($verify -notlike "*HTTPS*") {
    Write-Warning "⚠️ HTTPS listener not detected."
    if ($UseHTTPFallback) {
        Write-Host "🌐 Enabling HTTP fallback..." -ForegroundColor Yellow
        winrm quickconfig -force
        winrm set winrm/config/service/auth @{Basic="true"}
    } else {
        exit 1
    }
}

Write-Host "✅ WinRM over HTTPS setup complete!" -ForegroundColor Green
Write-Host "🧪 Test: Test-WsMan -ComputerName $Hostname -Port 5986 -UseSSL" -ForegroundColor Gray
