<#
.SYNOPSIS
    Configures WinRM over HTTPS using PFX import, CSR generation, or self-signed certificate.

.DESCRIPTION
    This script:
      - Validates execution as Administrator
      - Detects desired mode from parameters (PFX, CSR, self-signed)
      - Imports certificate OR generates CSR/self-signed cert
      - Configures WinRM HTTPS listener
      - Validates connectivity
      - Falls back to HTTP if enabled and HTTPS fails
      - Logs all actions with timestamps

.NOTES
    Author: Your Name
    Version: 2.0
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Hostname,

    [Parameter()]
    [string]$PfxPath = "",

    [Parameter()]
    [string]$CertPassword = "",

    [Parameter()]
    [bool]$GenerateCSR = $false,

    [Parameter()]
    [bool]$SelfSigned = $false,

    [Parameter()]
    [bool]$UseHTTPFallback = $true,

    [Parameter()]
    [string]$CertStoreLocation = "Cert:\LocalMachine\My",

    [Parameter()]
    [int]$KeyLength = 2048
)

function Write-Log {
    param ([string]$Message, [string]$Level = "INFO")
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Write-Host "[$timestamp][$Level] $Message"
}

function Check-Admin {
    if (-not ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Log "Script must be run as Administrator." "ERROR"
        exit 2
    }
}

function Generate-Csr {
    Write-Log "Generating CSR for $Hostname..." "ACTION"
    $infContent = @"
[Version]
Signature=`"$Windows NT$`"

[NewRequest]
Subject = "CN=$Hostname"
KeySpec = 1
KeyLength = $KeyLength
Exportable = TRUE
MachineKeySet = TRUE
RequestType = PKCS10

[EnhancedKeyUsageExtension]
OID=1.3.6.1.5.5.7.3.1  ; Server Authentication
"@
    $infPath = "$env:TEMP\winrm_https.inf"
    $csrPath = "$env:TEMP\winrm_https.req"

    $infContent | Out-File -FilePath $infPath -Encoding ascii
    certreq -new $infPath $csrPath

    if (Test-Path $csrPath) {
        Write-Log "CSR generated at $csrPath" "SUCCESS"
        Write-Log "Submit this CSR to your CA and rerun with -PfxPath" "INFO"
        exit 0
    }
    else {
        Write-Log "CSR generation failed" "ERROR"
        exit 3
    }
}

function Generate-SelfSigned {
    Write-Log "Generating self-signed certificate..." "ACTION"
    $cert = New-SelfSignedCertificate `
        -DnsName $Hostname `
        -CertStoreLocation $CertStoreLocation `
        -KeyExportPolicy Exportable `
        -KeyLength $KeyLength `
        -KeyAlgorithm RSA `
        -HashAlgorithm SHA256 `
        -Provider "Microsoft RSA SChannel Cryptographic Provider"

    if (-not $cert) {
        Write-Log "Failed to generate self-signed certificate." "ERROR"
        exit 4
    }
    return $cert
}

function Import-Pfx {
    Write-Log "Importing certificate from $PfxPath..." "ACTION"
    $securePass = ConvertTo-SecureString -String $CertPassword -AsPlainText -Force
    $cert = Import-PfxCertificate -FilePath $PfxPath -CertStoreLocation $CertStoreLocation -Password $securePass

    if (-not $cert) {
        Write-Log "Failed to import certificate." "ERROR"
        exit 5
    }
    return $cert
}

function Configure-WinRM {
    param ([string]$Thumbprint)
    Write-Log "Removing existing HTTPS listeners..." "ACTION"
    $existing = winrm enumerate winrm/config/listener | Where-Object { $_ -like "*Transport=HTTPS*" }
    foreach ($listener in $existing) {
        $id = ($listener -split 'ListenerId=')[-1].Trim()
        winrm delete "winrm/config/Listener?ListenerId=$id"
    }

    Write-Log "Creating HTTPS listener for $Hostname..." "ACTION"
    Invoke-Expression "winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname='$Hostname'; CertificateThumbprint='$Thumbprint'}"

    Restart-Service WinRM
}

function Validate-HTTPS {
    try {
        Test-WsMan -ComputerName $Hostname -Port 5986 -UseSSL -ErrorAction Stop | Out-Null
        Write-Log "HTTPS connectivity verified!" "SUCCESS"
        return $true
    }
    catch {
        Write-Log "HTTPS connectivity failed." "WARN"
        return $false
    }
}

# MAIN EXECUTION
Check-Admin
Write-Log "Starting WinRM configuration..." "INFO"

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
    Write-Log "No valid certificate input provided." "ERROR"
    exit 6
}

$thumbprint = $cert.Thumbprint.Trim()
Write-Log "Using certificate thumbprint: $thumbprint" "INFO"

Configure-WinRM -Thumbprint $thumbprint

if (-not (Validate-HTTPS) -and $UseHTTPFallback) {
    Write-Log "Enabling HTTP fallback listener..." "WARN"
    winrm quickconfig -force
    winrm set winrm/config/service/auth @{Basic="true"}
}
