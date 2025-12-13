# 🚀 BOOTSTRAP GUIDE

From **zero to fully provisioned machine** using **chezmoi + Ansible**.

This guide covers initializing a fresh system, installing prerequisites, and applying your full configuration stack.

---

## 🔹 Overview

The bootstrap process ensures:

1. **Base system readiness** (package managers, tools)
2. **User configuration deployment** (via `chezmoi`)
3. **OS-specific provisioning** (via `Ansible`)
4. **Idempotent, repeatable setup**

Supported platforms: **Windows, macOS, Ubuntu/Debian, Arch Linux, WSL**

---

## 1️⃣ Prerequisites

* Internet connectivity
* Administrative privileges (required for system-level provisioning)
* Git installed (if not present, bootstrap script will install)
* Optional: PowerShell 7+ for cross-platform scripting

---

## 2️⃣ Clone the Repository

```bash
# Linux/macOS/WSL
git clone https://github.com/your-username/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Windows (PowerShell)
git clone https://github.com/your-username/dotfiles.git $HOME\dotfiles
cd $HOME\dotfiles
```

---

## 3️⃣ Run Bootstrap Script

### Linux/macOS/WSL

```bash
# Make executable
chmod +x scripts/bootstrap/bootstrap.sh

# Run bootstrap
./scripts/bootstrap/bootstrap.sh
```

### Windows (PowerShell)

```powershell
# Open PowerShell as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force
.\scripts\bootstrap\bootstrap.ps1
```

The bootstrap script will:

1. Install package managers (`apt`, `pacman`, `brew`, `choco`, `winget` as appropriate)
2. Install **chezmoi**
3. Install **Ansible**
4. Apply initial **dotfiles**
5. Render templates per OS
6. Trigger **Ansible provisioning**

---

## 4️⃣ Verify Bootstrap

After running:

```bash
# Check dotfiles applied
chezmoi doctor

# Verify packages and services
ansible-playbook --syntax-check playbooks/<platform>/main.yml

# Optional: dry-run provisioning
ansible-playbook -i localhost, playbooks/<platform>/main.yml --check
```

---

## 5️⃣ Post-Bootstrap Validation

* All tools installed and functional
* Fonts installed and terminal configured
* OS-specific services running
* Firewall and security rules applied
* Remote access (e.g., SSH/WinRM) configured

> 💡 Philosophy: Machines are disposable; configuration is source-controlled. You can safely re-run the bootstrap script at any time.

---

## 6️⃣ Re-running Bootstrap

The bootstrap process is **idempotent**:

* Safe to run multiple times
* Will update dotfiles and system configuration
* Will not overwrite secrets or sensitive configuration unless explicitly modified

---

## 7️⃣ Troubleshooting

* **Bootstrap fails due to permissions:** Ensure you are running as Admin (Windows) or with `sudo` (Linux/macOS)
* **Network issues:** Verify internet connectivity and package manager access
* **Package manager conflicts:** Check system logs for installation errors
* **chezmoi issues:** Run `chezmoi doctor` to detect configuration problems
* **Ansible issues:** Use `ansible-playbook --check` to detect playbook syntax or dependency problems

---

## 8️⃣ Tips for Automation

* Integrate bootstrap into **CI/CD pipelines** for disposable VMs
* Use **environment variables** to control secrets, paths, or branch selection
* Combine bootstrap with **cloud-init** or provisioning scripts for automated cloud deployments

---

## 9️⃣ Reference Paths

```text
scripts/bootstrap/       # Bootstrap scripts
ansible/playbooks/       # OS-specific provisioning
docs/                    # Documentation & guides
secrets/                 # Vaulted secrets
```
