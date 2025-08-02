---
id: intro
title: 🧰 Introduction 
sidebar_position: 1
description: Cros-platform dotfiles automation powered by chezmoi and Ansible. Declarative setup. Developer-focused. Secure by default.
---

# 🧰 Cross-Platform dotfiles Automation

Unified system for managing dotfiles, provisioning systems, and enforcing security policies across macOS, Windows, Linux, Arch and WSL environments.

Built with [**chezmoi**](https://www.chezmoi.io) and [**Ansible**](https://www.ansible.com), this dotfiles focuses on **developer experience**, **compliance**, and **repeatable automation delivering consistency across every platform you touch.

---

## 💡 Why Use This dotfiles?

Whether you're a solo developer, part of a platform engineering team, or managing fleets of systems at scale, this dotfiles helps you:

- 🚀 Bootstrap new machines in minutes—repeatably and reliably  
- 🔒 Stay aligned with SOC 2 and ISO 27001 best practices  
- 🧠 Adapt your configuration per OS, architecture, or user role  
- 📚 Maintain living documentation via [**Docusaurus**](https://docusaurus.io)

---

## 🧰 Required Toolchain

| Tool | Purpose | Install Guide | Project Integration |
| --- | --- | --- | --- |
| **Chezmoi** | Dotfile templating and lifecycle hooks | [chezmoi.io/install](https://www.chezmoi.io/docs/install/) | Required for `.chezmoiscripts/` bootstrap |
| **Ansible** | OS provisioning and task execution | [Ansible Install Docs](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) | Core execution engine for playbooks |
| **Git** | Version control for dotfiles | Preinstalled or via package manager | Required for cloning `hetfs/dotfiles` |
| **Python 3.8+** | Ansible execution environment | `apt install python3` / `brew install python` | Required for control machine and nodes |

---

## 🧱 Architecture at a Glance

| Layer                | Tool | Purpose |
|---------------------|------|---------|
| 🧩 Dotfiles          | [chezmoi](https://www.chezmoi.io) | Cross-platform dotfile management and templating |
| ⚙️ Provisioning      | [Ansible](https://www.ansible.com) | Declarative configuration and package setup |
| 📦 Package Management| [APT](https://wiki.debian.org/Apt), [Homebrew](https://brew.sh), [Winget](https://learn.microsoft.com/en-us/windows/package-manager/winget), [pacman](https://wiki.archlinux.org/title/pacman), [paru](https://github.com/Morganamilo/paru) | Native provisioning per platform |
| 🔐 Secrets           | [chezmoi secrets](https://www.chezmoi.io/user-guide/secrets/), [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html), [sops](https://github.com/mozilla/sops), [age](https://github.com/FiloSottile/age) | Secure secrets management |
| 📚 Documentation     | [Docusaurus](https://docusaurus.io) | Interactive, versioned developer documentation |
| 🔁 GitOps Provisioning | [`ansible-pull`](https://docs.ansible.com/ansible/latest/cli/ansible-pull.html), `bootstrap.sh` | Automated setup from Git repositories |

---

## 🌍 Supported Platforms

This framework auto-detects and adapts to your platform:

| Platform      | Detection Logic                          | Role    | Package Manager |
|---------------|-------------------------------------------|---------|-----------------|
| **macOS**     | `ansible_os_family == "Darwin"`           | `macos` | [Homebrew](https://brew.sh) |
| **Windows**   | `ansible_os_family == "Windows"`          | `windows` | [Winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) |
| **Debian/Ubuntu** | `ansible_distribution in [...]`     | `debian` | [APT](https://wiki.debian.org/Apt) |
| **Arch Linux**| `ansible_distribution == "Archlinux"`     | `arch`   | [pacman](https://wiki.archlinux.org/title/pacman), [paru](https://github.com/Morganamilo/paru) |
| **WSL**       | Linux kernel + distro checks              | `wsl`    | [APT (via WSL)](https://wiki.debian.org/Apt) |

> 💡 **WSL** is treated as a first-class platform with integrated shell and file system support.

---

## 🚀 Quick Start

### All Platforms:

```bash
# Clone and initialize the project
chezmoi init https://github.com/hetfs/dotfiles
chezmoi apply
```

### Platform-Specific Bootstrap:

| Platform | Command |
| --- | --- |
| **Linux/macOS** | `curl -sL https://raw.githubusercontent.com/hetfs/dotfiles/main/scripts/chezmoi-init.sh \\| bash` |
| **Windows** | `irm win-bootstrap.ps1 \\| iex` |
| **WSL** | `curl -sL wsl-init.sh \\| bash` |

---

## 📦 Platform-Specific Setup

| Platform | Key Components | Architecture Notes |
| --- | --- | --- |
| 🐧 **Linux** | `playbooks/ubuntu/` or `playbooks/arch/` | Uses APT/Snap or Pacman/AUR tasks |
| 🍏 **macOS** | `playbooks/darwin/main.yml` | Requires `xcode-select --install` pre-brew |
| 🪟 **Windows** | `.chezmoitemplates/run_once_install.ps1.tmpl` | Executes via PowerShell with admin rights |
| 💠 **WSL** | `playbooks/wsl/main.yml` | Syncs dotfiles between Windows/Linux layers |

---

## 📁 Project Structure Highlights ([Full View](https://github.com/hetfs/dotfiles))

```bash
dotfiles/
├── .chezmoi*scripts/            # Platform hooks
├── .chezmoi*templates/          # Bootstrap scripts
├── ansible/playbooks/           # OS entrypoints
├── ansible/config/roles/        # Shared roles
├── secrets/                     # Encrypted vaults
├── scripts/                     # Bootstrap utilities
└── docs/                        # Architecture diagrams
```

---

## 🔐 Security Setup

1. **Configure GPG for Chezmoi**:
  
  ```bash
  gpg --full-generate-key
  chezmoi --gpg-recipient YOUR_ID add --encrypt ~/.ssh/id_rsa
  ```
  
2. **Ansible Vault Setup**:
  
  ```bash
  # Create vault password file
  echo "mysecret" > ~/.vault_pass
  chmod 600 ~/.vault_pass
  
  # Encrypt host variables
  ansible-vault encrypt ansible/config/host_vars/prod-server.yml
  ```

---

## 🧪 Quality Assurance

```bash
# Install test dependencies (from repo root)
pip install -r ansible/test/requirements.txt

# Run validation suite
cd ansible
ansible-lint playbooks/
yamllint .
molecule test
```

---

## 🚦 Preflight Checklist

| Task | Command | Verification |
| --- | --- | --- |
| Initialize repo | `chezmoi init hetfs/dotfiles` | `chezmoi doctor` |
| Install dependencies | `scripts/install-roles.sh` | `ansible-galaxy list` |
| Test connectivity | `ansible -i inventories/local all -m ping` | Successful ping |
| Validate secrets | `ansible-vault view secrets/ansible-vault/staging.yml` | Proper decryption |

---

## ⚠️ Troubleshooting

**Common Issues**:

- **Python Missing**: Bootstrap scripts auto-install Python on most platforms
- **Permission Errors**: Use `sudo` on Linux/macOS or Admin PowerShell on Windows
- **Secret Decryption Failures**: Ensure GPG key is in keyring or vault password is correct

**Debug Commands**:

```bash
# Verbose chezmoi output
chezmoi apply -v

# Ansible debug mode
ansible-playbook playbooks/ubuntu/main.yml -vvv

# Test specific role
molecule test -s base-role
```

---

## 🔐 Security and Compliance

Security is baked into every layer of this system:

- 🔒 **Dual-vault system**: Use both `chezmoi secrets` and `Ansible Vault`  
- 🧱 **Immutable by design**: Reapply setups with no side effects  
- 📝 **Audit-friendly**: Git-signed changes and timestamped diffs  
- ⚙️ **Environment-specific hardening**: Conditional templates for secure defaults

### 🗺️ System Diagram

```mermaid
graph LR
  A[chezmoi Templates] --> B{Ansible Controller}
  B --> C[SSH Hardening]
  B --> D[CIS Benchmarks]
  B --> E[FIPS Modules]
  C & D & E --> F[SIEM Integration]
````

---


## 📚 Resources

- [Project Documentation](https://github.com/hetfs/dotfiles/tree/main/docs)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Chezmoi Templating Guide](https://www.chezmoi.io/docs/reference/templates/)
- [Issue Tracker](https://github.com/hetfs/dotfiles/issues)

---

## 🧠 Core Philosophy

> **Declarative automation meets adaptive personalization.**

This framework follows **GitOps** and **conditional logic** principles. Every system becomes:

* Reproducible
* Secure by default
* Personalized without manual edits

---

> **Built for scale. Secured for compliance. Tuned for developers.**
>
> **Pro Tip**: Use `make dev` for development environment setup after bootstrap completes. For advanced configuration, see the [architecture documentation](https://github.com/hetfs/dotfiles/blob/main/docs/ARCHITECTURE.md).
