# winrm_cert_https Role

## 📜 Overview
This Ansible role automates the complete setup of **WinRM over HTTPS** on Windows hosts, including:

1. **Installing a certificate** – from a `.pfx` file, a generated CSR, or a self-signed certificate.
2. **Detecting the certificate thumbprint** automatically.
3. **Configuring an HTTPS WinRM listener** bound to the certificate.
4. **Enabling certificate authentication** for WinRM.
5. **Opening the firewall** for WinRM over HTTPS.
6. **Optional HTTP fallback** if HTTPS setup fails.

---

## ⚙️ Variables
All variables are defined in [`defaults/main.yml`](defaults/main.yml) and can be overridden in your inventory or playbooks.

### 🔹 General
| Variable | Default | Description |
|----------|---------|-------------|
| `winrm_hostname` | `{{ inventory_hostname }}` | Hostname or FQDN for the WinRM HTTPS listener and certificate CN. |

### 🔹 Certificate Options
| Variable | Default | Description |
|----------|---------|-------------|
| `winrm_cert_pfx_path` | `""` | Full path to a `.pfx` file on the Ansible control node to copy to the Windows host. Leave empty to trigger CSR or self-signed mode. |
| `winrm_cert_password` | `""` | Password for the `.pfx` file — **must be vaulted** in production. |
| `winrm_generate_csr` | `false` | Set to `true` to generate a CSR (`%TEMP%\winrm_https.req`). |
| `winrm_self_signed` | `false` | Auto-generate a self-signed certificate if no PFX and CSR is requested. |

### 🔹 Firewall and Fallback Options
| Variable | Default | Description |
|----------|---------|-------------|
| `win_firewall_profile` | `Any` | Windows Firewall profile to apply the rule to (`Any`, `Domain`, `Private`, `Public`). |
| `winrm_use_http_fallback` | `true` | If HTTPS fails, configure HTTP listener and update connection vars. |

---

## 🚀 Usage

### Example Playbook
```yaml
- hosts: windows_servers
  gather_facts: no
  roles:
    - role: winrm_cert_https
      vars:
        winrm_cert_pfx_path: "/path/to/winrm_cert.pfx"
        winrm_cert_password: "{{ vault_winrm_cert_password }}"
        win_firewall_profile: Domain
````

---

## 🗺 Usage Diagram

```mermaid
graph TD
    A["[Start Role Execution](tasks/main.yml)"] --> B{PFX File Provided?}
    B -- Yes --> C["[Import PFX into LocalMachine\\My](tasks/main.yml#L15)"]
    B -- No --> D{Generate CSR?}
    D -- Yes --> E["[Create CSR at %TEMP%\\winrm_https.req](tasks/main.yml#L30)"]
    D -- No --> F{Self-Signed Mode Enabled?}
    F -- Yes --> G["[Generate Self-Signed Certificate](tasks/main.yml#L45)"]
    F -- No --> H["[Fail: No certificate method selected](tasks/assert.yml)"]

    C --> I["[Detect Certificate Thumbprint](tasks/main.yml#L60)"]
    E --> I
    G --> I

    I --> J["[Configure WinRM HTTPS Listener](tasks/main.yml#L75)"]
    J --> K["[Enable Certificate Authentication](tasks/main.yml#L90)"]
    K --> L["[Open Firewall for TCP 5986](tasks/main.yml#L105)"]
    L --> M["[Test HTTPS Connectivity](tasks/main.yml#L120)"]
    M -- Success --> N[Role Complete]
    M -- Fail --> O{HTTP Fallback Enabled?}
    O -- Yes --> P["[Configure HTTP Listener + Firewall 5985](tasks/main.yml#L135)"]
    O -- No --> Q["[Fail Role](tasks/main.yml#L150)"]
    P --> N
```

---

## 📊 Certificate Method Decision Table

| Scenario             | `winrm_cert_pfx_path` | `winrm_generate_csr` | `winrm_self_signed` | Result                                                         |
| -------------------- | --------------------- | -------------------- | ------------------- | -------------------------------------------------------------- |
| **PFX Import**       | ✅ Non-empty path      | `false`              | `false` or `true`   | [Import `.pfx` into `LocalMachine\My`](tasks/main.yml#L15)     |
| **CSR Generation**   | Empty                 | `true`               | `false` or `true`   | [Generate CSR at `%TEMP%\winrm_https.req`](tasks/main.yml#L30) |
| **Self-Signed Cert** | Empty                 | `false`              | `true`              | [Auto-create self-signed cert](tasks/main.yml#L45)             |
| **Fail**             | Empty                 | `false`              | `false`             | [Fail: no cert method chosen](tasks/assert.yml)                |

---

## 🔄 Execution Flow (Task Mapping)

1. **Fail-fast Validation** – [`tasks/assert.yml`](tasks/assert.yml)
   Ensures at least one certificate method is chosen.

2. **Directory Setup** – [`tasks/main.yml#L10`](tasks/main.yml#L10)
   Creates target folder for certificates.

3. **Certificate Handling**:

   * [Import PFX](tasks/main.yml#L15)
   * [Generate CSR](tasks/main.yml#L30)
   * [Create Self-Signed Cert](tasks/main.yml#L45)

4. **Thumbprint Detection** – [`tasks/main.yml#L60`](tasks/main.yml#L60)

5. **HTTPS Listener Setup** – [`tasks/main.yml#L75`](tasks/main.yml#L75)

6. **Certificate Authentication** – [`tasks/main.yml#L90`](tasks/main.yml#L90)

7. **Firewall Rules** – [`tasks/main.yml#L105`](tasks/main.yml#L105)

8. **Connectivity Test** – [`tasks/main.yml#L120`](tasks/main.yml#L120)

9. **HTTP Fallback** *(optional)* – [`tasks/main.yml#L135`](tasks/main.yml#L135)

---

## 🔐 Security Notes

* Always **vault-encrypt** `winrm_cert_password`:

  ```bash
  ansible-vault encrypt_string 'SuperSecretPass!' --name 'winrm_cert_password'
  ```
* Restrict `.pfx` file access.
* If using self-signed certs, set:

  ```yaml
  ansible_winrm_server_cert_validation: ignore
  ```

---

## 🛠 Requirements

* Ansible `>= 2.10`
* Windows host with PowerShell 5.1+
* Python `pywinrm` installed on control node

---

## 📂 Role Structure

```
roles/
└── winrm_cert_https/
    ├── defaults/
    │   └── main.yml
    ├── files/
    │   └── setup-winrm-https.ps1
    ├── tasks/
    │   ├── assert.yml
    │   └── main.yml
    └── README.md
```

---

## 📌 Notes

* Role does **not** create DNS records — ensure `winrm_hostname` resolves.
* CSR mode requires external signing before importing cert.
