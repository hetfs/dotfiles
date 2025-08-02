---
id: ansible-config
title: ⚙️Architecture Configuration
description: Standardized cross-platform ansible.cfg strategy with overrides, vaulting, and plugin support.
sidebar_position: 2
---

# ⚙️ Ansible Configuration Architecture

This guide outlines the modular and cross-platform `ansible.cfg` setup tailored for automation with **Ansible + chezmoi**. It supports:

- 🔁 Relative inventory and role paths  
- 🔐 Secure vault decryption  
- 🖥 Platform-specific overrides  
- 🧩 Plugin support (filters, modules)  
- 🎯 CI-friendly, readable output  

---

## 📁 Directory Structure

```txt
ansible/
├── ansible.cfg          # Global defaults
├── secrets/.vault_pass.txt
├── common/
│   ├── roles/
│   ├── library/
│   └── filter_plugins/
├── inventories/
│   ├── windows/
│   ├── ubuntu/
│   └── ...
├── windows/ansible.cfg
├── ubuntu/ansible.cfg
├── darwin/ansible.cfg
└── ...
````

---

## 🔧 Shared Default Configuration (`ansible/ansible.cfg`)

```ini title="ansible/ansible.cfg"
[defaults]
roles_path = ./common/roles:~/.ansible/roles
inventory = ./inventories
stdout_callback = yaml
log_path = ./ansible.log
force_color = True
nocows = 1
deprecation_warnings = True
vault_password_file = ./secrets/.vault_pass.txt
retry_files_enabled = True
retry_files_save_path = ./retries
filter_plugins = ./common/filter_plugins
library = ./common/library

[privilege_escalation]
become = True
become_method = sudo
become_ask_pass = False

[ssh_connection]
pipelining = True
control_path = ~/.ansible/cp/ansible-ssh-%%h-%%p-%%r
control_master = auto
control_persist = 60s
```

---

## 🧠 Required Platform-Specific Overrides

Each OS **must** define its own `ansible.cfg` to support:

* OS-specific `inventory`
* Connection method (e.g. SSH, WinRM)
* Log file isolation
* Elevation behavior

---

### 🪟 `windows/ansible.cfg`

```ini title="windows/ansible.cfg"
[defaults]
inventory = ../inventories/windows
roles_path = ../common/roles
stdout_callback = yaml
log_path = ../ansible-windows.log
force_color = True
retry_files_enabled = True
retry_files_save_path = ../retries
vault_password_file = ../secrets/.vault_pass.txt
filter_plugins = ../common/filter_plugins
library = ../common/library

[connection]
connection = winrm

[privilege_escalation]
become = False
```

---

### 🐧 `ubuntu/ansible.cfg`

```ini title="ubuntu/ansible.cfg"
[defaults]
inventory = ../inventories/ubuntu
roles_path = ../common/roles
stdout_callback = yaml
log_path = ../ansible-ubuntu.log
force_color = True
vault_password_file = ../secrets/.vault_pass.txt
filter_plugins = ../common/filter_plugins
library = ../common/library

[privilege_escalation]
become = True
become_method = sudo
become_ask_pass = False

[ssh_connection]
pipelining = True
```

---

### 🍏 `darwin/ansible.cfg`

```ini title="darwin/ansible.cfg"
[defaults]
inventory = ../inventories/darwin
roles_path = ../common/roles
stdout_callback = yaml
log_path = ../ansible-darwin.log
force_color = True
vault_password_file = ../secrets/.vault_pass.txt
filter_plugins = ../common/filter_plugins
library = ../common/library

[privilege_escalation]
become = True
become_method = sudo
```

---

### 🅰️ `arch/ansible.cfg`

```ini title="arch/ansible.cfg"
[defaults]
inventory = ../inventories/arch
roles_path = ../common/roles
stdout_callback = yaml
log_path = ../ansible-arch.log
vault_password_file = ../secrets/.vault_pass.txt
retry_files_enabled = True
filter_plugins = ../common/filter_plugins
library = ../common/library

[privilege_escalation]
become = True
```

---

### 💠 `wsl/ansible.cfg`

```ini title="wsl/ansible.cfg"
[defaults]
inventory = ../inventories/wsl
roles_path = ../common/roles
stdout_callback = yaml
log_path = ../ansible-wsl.log
vault_password_file = ../secrets/.vault_pass.txt
filter_plugins = ../common/filter_plugins
library = ../common/library

[privilege_escalation]
become = True

[ssh_connection]
pipelining = True
```

---

## 🔐 Managing Vault Secrets

To securely automate decryption:

```bash
echo "myVaultPassword" > secrets/.vault_pass.txt
chmod 600 secrets/.vault_pass.txt
```

> ⚠️ Add `secrets/.vault_pass.txt` to `.gitignore` — never commit vault credentials.

---

## 🚀 Usage Pattern

Always run `ansible-playbook` from the platform folder so the correct config loads:

```bash
cd ubuntu && ansible-playbook main.yml
cd windows && ansible-playbook main.yml
```

---

## 🧠 Bonus: Auto-Detect Host?

 `run.sh` script that detects the platform and uses the correct config. Let me know if you want help automating that.
