---
id: running-ansible-natively-win
title: 🪟 Running Ansible Natively on Windows
description: Guide to installing Ansible and configuring WinRM for managing Windows hosts directly from a native Windows control node.
sidebar_position: 10
---

# 🪟 Running Ansible Natively on Windows

While Ansible is built for Unix-like systems, you can run it on **Windows natively** in Windows-only environments. This setup is useful for development and testing, but **not recommended for production**.

> ✅ For full Ansible support with Linux modules, SSH, and cross-platform automation, use [WSL](./win-ansible-install.md) or a Linux VM.

---

## ⚙️ Step-by-Step: Installing Ansible on Windows

### 1. 🐍 Install Python

- Download and install the latest Python 3.x from [python.org](https://www.python.org/)
- ✅ Make sure to enable **“Add Python to PATH”** during installation

---

### 2. 📦 Install Ansible and pywinrm

Open **PowerShell as Administrator** and run:

```powershell
pip install ansible
pip install pywinrm
````

> ⚠️ If `pip` isn't recognized, restart PowerShell or ensure Python was added to PATH.

---

## 🚧 Native Windows Limitations

| ⚠️ Area   | Limitation                                                          |
| --------- | ------------------------------------------------------------------- |
| Modules   | No support for Linux-only modules like `apt`, `yum`, `systemd`      |
| Target OS | Can only manage **Windows** hosts                                   |
| SSH       | Not reliable without extra setup                                    |
| Paths     | File path differences (e.g., `/etc/hosts` vs `C:\Windows\System32`) |
| Community | Limited support, no official production guidance                    |

---

## 🖥️ Managing Windows Hosts with Ansible (via WinRM)

To manage Windows hosts, **WinRM must be properly configured**.

---

## 🔧 Basic WinRM Setup (on Windows Target)

Run the following **on each Windows host** (as Administrator):

```powershell
Enable-PSRemoting -Force -SkipNetworkProfileCheck
```

> This sets up the HTTP WinRM listener and configures basic firewall rules.

---

### Optional WinRM Hardening

```powershell
# Set trusted hosts (workgroup-only)
winrm set winrm/config/client '@{TrustedHosts="192.168.1.*"}'

# Disable unencrypted traffic (requires HTTPS setup)
winrm set winrm/config/service '@{AllowUnencrypted="false"}'

# Enable Basic authentication
winrm set winrm/config/service/auth '@{Basic="true"}'
```

---

## 🧪 Verifying WinRM Configuration

### ✅ Check listeners

```powershell
winrm enumerate winrm/config/listener
```

### ✅ View full config

```powershell
winrm get winrm/config
```

### ✅ Verify local endpoint (HTTP)

```powershell
winrm id -r:http://localhost:5985/wsman
```

### ✅ Test listener ports

```powershell
Test-NetConnection -ComputerName localhost -Port 5985
Test-NetConnection -ComputerName localhost -Port 5986
```

### ✅ Check firewall rules

```powershell
Get-NetFirewallRule -Name "WinRM*" | Select-Object Name, Enabled
```

---

## 🔥 Open Required Firewall Ports

```powershell
New-NetFirewallRule -Name "WinRM-HTTP" -DisplayName "WinRM HTTP" -Enabled True `
  -Profile Any -Action Allow -Direction Inbound -LocalPort 5985 -Protocol TCP

New-NetFirewallRule -Name "WinRM-HTTPS" -DisplayName "WinRM HTTPS" -Enabled True `
  -Profile Any -Action Allow -Direction Inbound -LocalPort 5986 -Protocol TCP
```

---

## 🔐 Create WinRM HTTPS Listener (Optional for Secure Production)

1. Install or generate a certificate in the `LocalMachine\My` store
2. Get the thumbprint:

```powershell
Get-ChildItem -Path Cert:\LocalMachine\My
```

3. Create HTTPS listener:

```powershell
$thumbprint = "ABCDEF1234567890..."
winrm create winrm/config/Listener?Address=*+Transport=HTTPS `
"@{Hostname=`"$env:COMPUTERNAME`"; CertificateThumbprint=`"$thumbprint`"}"
```

---

## 🧼 Reset or Recreate WinRM Listeners

```powershell
# Delete all existing listeners
winrm delete winrm/config/Listener?Address=*+Transport=HTTP
winrm delete winrm/config/Listener?Address=*+Transport=HTTPS

# Recreate HTTP listener
winrm create winrm/config/Listener?Address=*+Transport=HTTP
```

---

## ✅ Verifying Ansible on Windows (Control Node)

### 1. Check Ansible version

```powershell
ansible --version
```

### 2. Confirm pywinrm is installed

```powershell
pip show pywinrm
```

---

## 📡 Test a Localhost Connection

Create an inventory file `hosts.ini`:

```ini
[windows]
localhost ansible_connection=local
```

Run:

```powershell
ansible -i hosts.ini windows -m ping
```

Expected:

```json
localhost | SUCCESS => { "ping": "pong" }
```

---

## 🧪 Test a Remote Windows Host (via WinRM)

Update `hosts.ini`:

```ini
[windows]
192.168.1.101
```

Run with:

```powershell
ansible -i hosts.ini windows -m win_ping -u Administrator -k
```

Expected:

```json
192.168.1.101 | SUCCESS => { "ping": "pong" }
```

> 💡 Use `win_ping` for Windows — the regular `ping` module only works on Linux.

---

## 🌐 Test from a Linux/macOS Control Node

```bash
ansible -i <IP>, all -m win_ping \
  -e "ansible_user=<USER> ansible_password=<PASS> \
      ansible_connection=winrm ansible_winrm_transport=ntlm"
```

> Replace `<IP>`, `<USER>`, and `<PASS>` as needed. You may also use `--ask-pass` or `--ask-vault-pass`.

---

## 🧾 WinRM Commands Cheat Sheet

| Command                                  | Description                            |
| ---------------------------------------- | -------------------------------------- |
| `winrm quickconfig`                      | One-step WinRM setup                   |
| `winrm get winrm/config`                 | Show full configuration                |
| `winrm set winrm/config/...`             | Set config values (e.g., TrustedHosts) |
| `winrm enumerate winrm/config/listener`  | List active listeners                  |
| `winrm delete winrm/config/Listener?...` | Remove specific listeners              |
| `winrm create winrm/config/Listener?...` | Create HTTP/HTTPS listeners            |
| `winrm id`                               | Get local endpoint info                |
| `Test-WSMan`                             | Confirm if WS-Management is active     |
| `Test-NetConnection -Port 5985/5986`     | Check if WinRM ports are open          |
| `Enable-PSRemoting`                      | Enables WinRM and firewall rules       |
| `Disable-PSRemoting`                     | Turns off WinRM                        |
| `Get-NetFirewallRule -Name "WinRM*"`     | Check WinRM firewall rules             |

---

## ✅ Final Checklist

| Task                   | Command                                           |
| ---------------------- | ------------------------------------------------- |
| Ansible installed      | `ansible --version`                               |
| Local ping works       | `ansible -i hosts.ini windows -m ping`            |
| Remote win\_ping works | `ansible -i hosts.ini windows -m win_ping -u ...` |
| WinRM port open        | `Test-NetConnection -Port 5985`                   |
| Listener active        | `winrm enumerate winrm/config/listener`           |

---

Looking for a more complete and supported approach?
Check out [Installing Ansible via WSL](./win-ansible-install.md) or use our [WinRM Setup Script](../scripts/winrm_https_setup.ps1) to automate HTTPS configuration.

