<#
.SYNOPSIS
Configure WinRM over HTTPS with a self-signed cert if no CA cert provided.
.DESCRIPTION
- Creates or imports a certificate with subject alternative names
- Binds the certificate to a WinRM HTTPS listener
- Configures firewall rules
- Exports PFX optionally
.PARAMETER Subject
Subject CN for certificate (default: machine name)
.PARAMETER DnsNames
Array of DNS SANs
.PARAMETER ExportPfx
Path to export PFX (optional)
#>
param(
[string]$Subject = $env:COMPUTERNAME,
[string[]]$DnsNames = @($env:COMPUTERNAME),
[string]$ExportPfx = ''
)


Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'


function New-SelfSignedCertWithSAN {
param($Subject, $DnsNames)
$san = "dns=$($DnsNames -join ',dns=')"
$cert = New-SelfSignedCertificate -Subject "CN=$Subject" -DnsName $DnsNames -KeyUsage DigitalSignature, KeyEncipherment -TextExtension @("2.5.29.17={text}$san") -CertStoreLocation Cert:\LocalMachine\My -NotAfter (Get-Date).AddYears(5)
return $cert
}


$cert = New-SelfSignedCertWithSAN -Subject $Subject -DnsNames $DnsNames
if (-not $cert) { throw 'Certificate creation failed' }


# Get thumbprint
$thumb = $cert.Thumbprint


# Remove existing HTTPS listeners
Get-ChildItem -Path WSMan:\LocalHost\Listener | Where-Object { $_.Keys -match 'Transport=HTTPS' } | ForEach-Object { Remove-Item -Path $_.PSPath -Recurse -Force }


# Create new HTTPS listener
$ip = '0.0.0.0'
$port = 5986
$listener = New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -Force
# Set certificate thumbprint on listener
Set-Item -Path WSMan:\LocalHost\Listener\MSFT_WinRMListener\@{CertificateThumbprint=$thumb}


# Configure WinRM service
winrm quickconfig -q
winrm set winrm/config/service @{AllowUnencrypted="false
