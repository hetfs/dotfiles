# setup-winrm-https.ps1

## Overview

`setup-winrm-https.ps1` is a PowerShell script designed to automate the configuration of **Windows Remote Management (WinRM) over HTTPS** on Windows hosts. It supports multiple certificate provisioning modes, including:

* Importing an existing `.pfx` certificate with a password
* Generating a Certificate Signing Request (CSR) for external CA signing
* Creating a self-signed certificate locally

The script then configures WinRM with the chosen certificate, validates connectivity, and optionally falls back to HTTP if HTTPS setup fails.

---

## Features

* **Multi-mode certificate provisioning:** Import PFX, generate CSR, or self-signed cert
* **Admin privilege check:** Ensures script runs with Administrator rights
* **Configurable certificate store location and RSA key length**
* **WinRM HTTPS listener setup with cleanup of existing listeners**
* **HTTPS connectivity validation**
* **Optional HTTP fallback with Basic authentication enabled**
* **Verbose logging with timestamps for easier troubleshooting**
* **Explicit exit codes for automation/Ansible integration**

---

## Requirements

* Windows host with PowerShell 5.1 or later
* Administrative privileges (Run PowerShell as Administrator)
* If importing PFX, the certificate file and password
* If generating CSR, access to a CA to sign and provide the signed certificate

---

## Parameters

| Parameter            | Type   | Required | Default                 | Description                                                                                      |
| -------------------- | ------ | -------- | ----------------------- | ------------------------------------------------------------------------------------------------ |
| `-Hostname`          | String | Yes      | N/A                     | Hostname or FQDN to be used as the certificate Subject CN and WinRM listener hostname            |
| `-PfxPath`           | String | No       | Empty string            | Path to the `.pfx` certificate file to import                                                    |
| `-CertPassword`      | String | No       | Empty string            | Password for the `.pfx` certificate. Should be securely handled                                  |
| `-GenerateCSR`       | Bool   | No       | `$false`                | When `$true`, generates a CSR and exits. Requires external CA signing before re-running with PFX |
| `-SelfSigned`        | Bool   | No       | `$false`                | When `$true`, generates a self-signed certificate locally                                        |
| `-UseHTTPFallback`   | Bool   | No       | `$true`                 | If HTTPS connectivity fails, fallback to HTTP listener with Basic auth enabled                   |
| `-CertStoreLocation` | String | No       | `Cert:\LocalMachine\My` | Certificate store location to import or generate certificates                                    |
| `-KeyLength`         | Int    | No       | `2048`                  | RSA key length used for CSR or self-signed cert generation                                       |

---

## How It Works

1. **Checks for administrator privileges:** exits if not elevated.
2. **Determines certificate provisioning mode:** based on input parameters.

   * If `-GenerateCSR` is `$true`, it generates a CSR file at `%TEMP%\winrm_https.req` and exits.
   * If `-PfxPath` points to a valid file, it imports the PFX certificate.
   * If `-SelfSigned` is `$true`, it creates a self-signed certificate.
   * Otherwise, it exits with an error.
3. **Configures WinRM HTTPS listener:** cleans existing HTTPS listeners, then creates a new listener bound to the certificate thumbprint.
4. **Restarts WinRM service** to apply changes.
5. **Validates HTTPS connectivity:** uses `Test-WSMan` to verify that WinRM HTTPS is functional.
6. **Optional HTTP fallback:** if HTTPS connectivity fails and fallback is enabled, configures a HTTP listener with Basic auth enabled.

---

## Usage Examples

### Import a PFX certificate and configure WinRM HTTPS:

```powershell
.\setup-winrm-https.ps1 -Hostname "server.example.com" `
    -PfxPath "C:\certs\winrm_cert.pfx" `
    -CertPassword "SuperSecretPass!"
```

### Generate a CSR for external CA signing (then submit CSR and re-run with PFX):

```powershell
.\setup-winrm-https.ps1 -Hostname "server.example.com" -GenerateCSR $true
# CSR is generated at %TEMP%\winrm_https.req
# Submit CSR to CA, obtain signed cert in PFX format, then re-run with -PfxPath
```

### Generate a self-signed certificate and configure WinRM HTTPS:

```powershell
.\setup-winrm-https.ps1 -Hostname "server.example.com" -SelfSigned $true
```

### Disable HTTP fallback (only use HTTPS):

```powershell
.\setup-winrm-https.ps1 -Hostname "server.example.com" -SelfSigned $true -UseHTTPFallback $false
```

---

## Exit Codes

| Code | Meaning                                    |
| ---- | ------------------------------------------ |
| 0    | Success or CSR generated (exits after CSR) |
| 1    | Missing or invalid certificate input       |
| 2    | Not running as Administrator               |
| 3    | CSR generation failed                      |
| 4    | Self-signed certificate generation failed  |
| 5    | PFX certificate import failed              |
| 6    | General failure or unknown error           |

---

## Logging

All output includes timestamps and log levels for easier troubleshooting. Example:

```
[2025-08-08 20:00:00][INFO] Starting WinRM configuration...
[2025-08-08 20:00:02][ACTION] Importing certificate from C:\certs\winrm_cert.pfx...
[2025-08-08 20:00:04][SUCCESS] Using certificate thumbprint: ABCD1234EF56...
[2025-08-08 20:00:06][WARN] HTTPS connectivity failed. Enabling HTTP fallback...
```

---

## Security Notes

* Always run the script in an elevated PowerShell session (Administrator).
* Protect the PFX file and password, especially in production environments.
* If using self-signed certificates, clients must be configured to trust the cert or ignore validation (`ansible_winrm_server_cert_validation: ignore`).
* When generating a CSR, submit it to a trusted Certificate Authority and obtain a signed certificate before re-running with the PFX import mode.

---

## Troubleshooting

* If WinRM HTTPS listener fails to create, verify that no conflicting listeners exist (`winrm enumerate winrm/config/listener`).
* Check Windows Event Logs for WinRM errors.
* Confirm firewall rules allow inbound TCP 5986 traffic.
* Use `Test-WSMan -ComputerName <hostname> -Port 5986 -UseSSL` manually to test connectivity.

---

## License

MIT License — free to use and modify.

---

## Author & Support

Created and maintained by Fredaws Lomdo HETFS LTD
