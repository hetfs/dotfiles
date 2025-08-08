<#
.SYNOPSIS
    Configures WinRM over HTTPS using PFX import, CSR generation, or self-signed cert based on input parameters.

.DESCRIPTION
    This script:
      - Detects desired mode from parameters (PFX, CSR, self-signed)
      - Imports certificate OR generates CSR/self-signed cert
      - Configures WinRM HTTPS listener
      - Validates connectivity
      - Falls back to HTTP if enabled and HTTPS fails
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$Hostname,

    [Parameter(Mandatory = $false)]
    [string]$PfxPath = "",

    [Parameter(Mandatory = $false)]
    [string]$CertPassword = "",

    [Parameter(Mandatory = $false)]
    [bool]$GenerateCSR = $false,

    [Parameter(Mandatory = $false)]
    [bool]$SelfSigned = $false,

    [Parameter(Mandatory = $false)]
    [bool]$UseHTTPFallback = $true
)

function Generate-Csr {
    Write-Host "📄 Generating CSR for $Hostname ..." -ForegroundColor Cyan

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

    Write-Host "✅ CSR generated at: $csrPath" -ForegroundColor Green
    Write-Host "➡️ Submit this CSR to your CA and rerun with -PfxPath when ready."
    exit 0
}

function Generate-SelfSigned {
    Write-Host "🔑 Generating self-signed certificate for $Hostname ..." -ForegroundColor Cyan
    $cert = New-SelfSignedCertificate `
        -DnsName $Hostname `
        -CertStoreLocation "Cert:\LocalMachine\My" `
        -KeyExportPolicy Exportable `
        -KeyLength 2048 `
        -KeyAlgorithm RSA `
        -HashAlgorithm SHA256 `
        -Provider "Microsoft RSA SChannel Cryptographic Provider"

    if (-not $cert) {
        Write-Error "❌ Failed to generate self-signed certificate."
        exit 1
    }

    return $cert
}

function Import-Pfx {
    Write-Host "📥 Importing certificate from $PfxPath ..." -ForegroundColor Cyan
    $securePass = ConvertTo-SecureString -String $CertPassword -AsPlainText -Force
    $cert = Import-PfxCertificate -FilePath $PfxPath -CertStoreLocation "Cert:\LocalMachine\My" -Password $securePass

    if (-not $cert) {
        Write-Error "❌ Failed to import the certificate."
        exit 1
    }

    return $cert
}

function Configure-WinRM {
    param (
        [string]$Thumbprint
    )

    Write-Host "🧹 Removing existing HTTPS listeners..." -ForegroundColor Yellow
    $existingListeners = winrm enumerate winrm/config/listener | Where-Object { $_ -like "*Transport=HTTPS*" }
    if ($existingListeners) {
        foreach ($listener in $existingListeners) {
            $id = ($listener -split 'ListenerId=')[-1].Trim()
            winrm delete "winrm/config/Listener?ListenerId=$id"
        }
    }

    Write-Host "🔧 Creating HTTPS listener..." -ForegroundColor Yellow
    $cmd = "winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname='$Hostname'; CertificateThumbprint='$Thumbprint'}"
    Invoke-Expression $cmd

    Write-Host "🔁 Restarting WinRM..." -ForegroundColor Yellow
    Restart-Service WinRM
}

function Validate-HTTPS {
    try {
        Test-WsMan -ComputerName $Hostname -Port 5986 -UseSSL -ErrorAction Stop | Out-Null
        Write-Host "✅ HTTPS connectivity verified!" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Warning "⚠️ HTTPS connectivity failed."
        return $false
    }
}

# ------------------------------
# Mode auto-detection
# ------------------------------
Write-Host "🚀 Starting WinRM configuration..." -ForegroundColor Cyan

$cert = $null

if ($GenerateCSR) {
    Generate-Csr
}
elseif ($PfxPath -and (Test-Path $PfxPath)) {
    $cert = Import-Pfx
}
elseif ($SelfSigned) {
    $cert = Generate-SelfSigned
}
else {
    Write-Error "❌ No valid certificate input provided. Use -PfxPath, -GenerateCSR, or -SelfSigned."
    exit 1
}

$thumbprint = $cert.Thumbprint.Trim()
Write-Host "🔎 Using certificate thumbprint: $thumbprint" -ForegroundColor Green

Configure-WinRM -Thumbprint $thumbprint

if (-not (Validate-HTTPS) -and $UseHTTPFallback) {
    Write-Host "🌐 Enabling HTTP fallback listener..." -ForegroundColor Yellow
    winrm quickconfig -force
    winrm set winrm/config/service/auth @{Basic="true"}
}
