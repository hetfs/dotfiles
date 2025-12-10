# 🚀 Quickstart

Use this guide to bootstrap your environment with **chezmoi** and **Ansible**.

---

## 1. Install chezmoi

For macOS, Linux, WSL, and Windows with Git Bash:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
```

This installs chezmoi globally for managing your configuration files.

---

## Recommended: PowerShell one-liner (official install script)

Run this in **PowerShell** (Admin recommended):

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
iex "& { $(irm 'https://get.chezmoi.io/ps1') }"
```

**How it works:**

* The execution policy is relaxed only for the current session.
* `irm` downloads the installer. `iex` runs it.
  Official documentation: [chezmoi.io][1]

If `irm` is blocked, use this fallback:

```powershell
Invoke-WebRequest -Uri 'https://get.chezmoi.io/ps1' -UseBasicParsing -OutFile "$env:TEMP\chezmoi-install.ps1"
& "$env:TEMP\chezmoi-install.ps1"
```

If you run into issues with the one-liner, switch to one of the package manager options.
More details here: [GitHub issue][2]

---

## Alternative 1: Winget

If Windows Package Manager is installed:

```powershell
winget install -e --id twpayne.chezmoi
```

This installs chezmoi from the official winget catalog.
Reference: [Winstall][3]

---

## Alternative 2: Chocolatey

```powershell
choco install chezmoi
```

Chocolatey provides a community-maintained package.
Reference: [Chocolatey Software][4]

---

## Alternative 3: Scoop

```powershell
scoop bucket add extras
scoop install chezmoi
```

A simple option if you prefer Scoop for user-level tools.

---

## 2. Initialize dotfiles

Clone and initialize your dotfiles:

```bash
chezmoi init https://github.com/hetfs/dotfiles
```

This fetches templates and supports encrypted secrets stored under `secrets/chezmoi`.

---

## 3. Apply dotfiles

Apply configuration to your system:

```bash
chezmoi apply
```

This places files in your home directory and decrypts secrets as needed.

---

## 4. Provision your OS with Ansible

Run the platform-specific playbook:

```bash
cd ansible

# Example for Ubuntu
ansible-galaxy install -r playbooks/ubuntu/requirements.yml
ansible-playbook playbooks/ubuntu/main.yml
```

This step:

* Installs platform dependencies.
* Runs shared and OS-specific tasks.
* Applies security hardening when enabled.

> **Tip:** Swap `ubuntu` with `windows`, `darwin`, `arch`, or `wsl` as needed.

---

## 5. Verify setup

Check that dotfiles applied correctly:

```bash
chezmoi diff
```

Run a dry-run of your platform playbook:

```bash
ansible-playbook playbooks/<platform>/main.yml --check
```

This confirms everything is consistent and idempotent.

---

### Learner Notes

* Chezmoi handles your dotfiles; Ansible manages system-level provisioning.
* You can re-run both tools safely at any time to sync changes.
* Secrets remain protected through encrypted storage.

---

[1]: https://chezmoi.io/install/?utm_source=chatgpt.com "Install"
[2]: https://github.com/twpayne/chezmoi/issues/3749?utm_source=chatgpt.com "Powershell one-line install on Windows 11 error"
[3]: https://winstall.app/apps/twpayne.chezmoi?utm_source=chatgpt.com "Install chezmoi with winget"
[4]: https://community.chocolatey.org/packages/chezmoi/2.59.0?utm_source=chatgpt.com "Chocolatey Software | chezmoi 2.59.0"
