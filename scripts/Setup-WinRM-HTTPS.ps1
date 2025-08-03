 #
.SYNOPSIS
    Sets up WinRM over HTTPS using a valid TLS certificate (.pfx) issued by a trusted CA, or auto-generates a CSR.

.DESCRIPTION
    This script automates:
    - Importing a .pfx certificate into the local machine certificate store
    - OR generating a Certificate Signing Request (CSR) for CA issuance
    - Creating a secure WinRM listener
    - Restarting the WinRM service
    - Verifying listener configuration
    - Optionally falling back to HTTP listener for troubleshooting

.PARAMETER PfxPath
    Full path to the .pfx certificate file.

.PARAMETER CertPassword
    Password for the .pfx file.

.PARAMETER Hostname
    The FQDN or hostname to bind the HTTPS listener to.

.PARAMETER GenerateCSR
    Switch to trigger automatic CSR generation instead of importing a PFX.

.PARAMETER UseHTTPFallback
    Switch to enable fallback HTTP listener for debugging if HTTPS setup fails.

.EXAMPLE
    .\Setup-WinRM-HTTPS.ps1 -PfxPath "C:\certs\mycert.pfx" -CertPassword "securepass" -Hostname "myhost.example.com"

.EXAMPLE
    .\Setup-WinRM-HTTPS.ps1 -GenerateCSR -Hostname "myhost.example.com"
#>

param (
    [Parameter(Mandatory = $false)]
    [string]$PfxPath,

    [Parameter(Mandatory = $false)]
    [string]$CertPassword,

    [Parameter(Mandatory = $true)]
    [string]$Hostname,

    [switch]$GenerateCSR,

    [switch]$UseHTTPFallback
)

function Generate-Csr {
    $infContent = @"
[Version]
Signature=`"$Windows NT$`"

[NewRequest]
Subject = "CN=$Hostname"
KeySpec = 1
KeyLength = 2048
Exportable = TRUE
MachineKeySet = TRUE
SMIME = FALSE
PrivateKeyArchive = FALSE
UserProtected = FALSE
UseExistingKeySet = FALSE
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
ProviderType = 12
RequestType = PKCS10
KeyUsage = 0xa0

[EnhancedKeyUsageExtension]
OID=1.3.6.1.5.5.7.3.1  ; Server Authentication
"@

    $infPath = "$env:TEMP\winrm_https.inf"
    $csrPath = "$env:TEMP\winrm_https.req"

    $infContent | Out-File -FilePath $infPath -Encoding ascii
    certreq -new $infPath $csrPath

    Write-Host "📤 CSR generated at: $csrPath" -ForegroundColor Green
    Write-Host "➡️ Submit this CSR to your Certificate Authority and import the issued certificate with -PfxPath when ready."
    exit 0
}

Write-Host "🔐 Setting up WinRM over HTTPS..." -ForegroundColor Cyan

if ($GenerateCSR) {
    Generate-Csr
}

if (-not (Test-Path $PfxPath)) {
    Write-Error "❌ .pfx file not found at: $PfxPath"
    exit 1
}

Write-Host "📥 Importing certificate..." -ForegroundColor Yellow
$SecurePass = ConvertTo-SecureString -String $CertPassword -AsPlainText -Force

$cert = Import-PfxCertificate -FilePath $PfxPath `
    -CertStoreLocation Cert:\LocalMachine\My `
    -Password $SecurePass

if (-not $cert) {
    Write-Error "❌ Failed to import the certificate."
    exit 1
}

$thumbprint = $cert.Thumbprint.Trim()
Write-Host "🔎 Certificate Thumbprint: $thumbprint" -ForegroundColor Green

# Remove existing HTTPS listeners
Write-Host "🧹 Removing existing HTTPS listeners..." -ForegroundColor Yellow
$existingListeners = winrm enumerate winrm/config/listener |
    Where-Object { $_ -like "*Transport=HTTPS*" }

if ($existingListeners) {
    foreach ($listener in $existingListeners) {
        $id = ($listener -split 'ListenerId=')[-1].Trim()
        winrm delete "winrm/config/Listener?ListenerId=$id"
    }
}

# Create new HTTPS listener
Write-Host "🔧 Creating WinRM HTTPS listener..." -ForegroundColor Yellow
$command = "winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=\"$Hostname\"; CertificateThumbprint=\"$thumbprint\"}"
Invoke-Expression $command

# Restart WinRM
Write-Host "🔁 Restarting WinRM service..." -ForegroundColor Yellow
Restart-Service WinRM

# Verify
Write-Host "🔍 Verifying listener..." -ForegroundColor Yellow
$listenerOutput = winrm enumerate winrm/config/listener
Write-Host $listenerOutput

if ($listenerOutput -notlike "*HTTPS*") {
    Write-Warning "⚠️ HTTPS listener not detected."
    if ($UseHTTPFallback) {
        Write-Host "🌐 Creating fallback HTTP listener..." -ForegroundColor Yellow
        winrm quickconfig -force
        winrm set winrm/config/service/auth @{Basic="true"}
    }
}

Write-Host "✅ WinRM configuration completed!" -ForegroundColor Green
Write-Host "🧪 Test with: Test-WsMan -ComputerName $Hostname -Port 5986 -UseSSL" -ForegroundColor Gray
