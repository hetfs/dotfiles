# 🛠 Maintenance Guide

This document outlines best practices for maintaining, updating, and validating the **cross-platform modular dotfiles repository**. Following these guidelines ensures your configurations remain **secure, reproducible, and CI-friendly**.

---

## 🔹 1. Updating Dotfiles

### Pull Latest Changes

```bash
cd ~/.dotfiles
git pull origin main
```

### Apply Updates with chezmoi

```bash
chezmoi apply
```

* Template changes automatically render per platform.
* Use `chezmoi diff` to preview changes before applying.

### Verify Environment-Specific Overrides

* Check `data/<platform>.yaml` for overrides.
* Ensure environment variables like `DOTFILES_ENV` are set correctly.

---

## 🔹 2. Managing Secrets

### Editing Secrets

* **chezmoi secrets**:

```bash
chezmoi secret edit <file>
```

* **Ansible Vault**:

```bash
ansible-vault edit secrets/ansible-vault/<file>.yml
```

### Best Practices

* Never commit secrets in plaintext.
* Maintain environment-based overrides for dev/staging/prod.

---

## 🔹 3. Updating Tools and Packages

### Linux

* **Ubuntu/Debian**:

```bash
sudo apt update && sudo apt upgrade -y
sudo snap refresh
```

* **Arch**:

```bash
sudo pacman -Syu --noconfirm
```

### macOS

```bash
brew update && brew upgrade
mas upgrade
```

### Windows

* **Chocolatey**:

```powershell
choco upgrade all -y
```

* **Winget**:

```powershell
winget upgrade --all
```

---

## 🔹 4. Plugin & Font Maintenance

### Fonts

* Managed via platform-specific tasks:

```bash
chezmoi apply --include fonts
ansible-playbook playbooks/<platform>/tasks/fonts.yml
```

### CLI Plugins

* Update tools like `fzf`, `starship`, `bat`, etc., using your platform’s package manager.
* For Neovim plugins:

```bash
nvim +PackerSync +qa
```

---

## 🔹 5. Version Control Discipline

* Branching strategy: `main` for stable, `dev` for ongoing changes.
* Commit messages: follow conventional commits:

```
feat: add new tool
fix: correct font installation
docs: update README
```

* Tag releases with semantic versioning: `v2.1.0`.

---

## 🔹 6. Continuous Integration (CI)

* CI ensures your dotfiles and provisioning scripts are **idempotent and functional**.

* Typical checks:

  * Syntax linting (YAML, PowerShell, Shell scripts)
  * Template rendering validation
  * Package installation dry-run
  * Secrets redaction

* Example CI commands:

```bash
chezmoi diff
ansible-playbook --check playbooks/<platform>/main.yml
```

---

## 🔹 7. Platform-Specific Maintenance

| Platform | Notes                                                            |
| -------- | ---------------------------------------------------------------- |
| Windows  | Ensure WinRM HTTPS listener is valid; update PowerShell modules. |
| macOS    | Reinstall Homebrew casks after major OS upgrades.                |
| Ubuntu   | Refresh APT keys and Snap channels periodically.                 |
| Arch     | Rebuild AUR packages if PKGBUILD changes.                        |
| WSL      | Sync both Linux and Windows tool updates.                        |

---

## 🔹 8. Backup & Rollback

* Keep a **snapshot of exported dotfiles** before major updates:

```bash
chezmoi cd
git tag pre-update-<date>
```

* Rollback example:

```bash
git checkout pre-update-2025-12-13
chezmoi apply
```

---

## 🔹 9. Health Checks

After any update:

1. Validate shell configuration:

```bash
echo $SHELL
chezmoi doctor
```

2. Verify installed tools:

```bash
git --version
nvim --version
starship --version
```

3. Validate WinRM (Windows only):

```powershell
Test-WSMan -ComputerName localhost -UseSSL
```

4. Check fonts availability:

```bash
fc-list | grep -i Nerd
```

---

## 🔹 10. Philosophy

> Machines are ephemeral. Configuration and reproducibility are permanent.

Maintaining dotfiles ensures **fast onboarding**, **consistent environments**, and **secure deployments** across all platforms.
