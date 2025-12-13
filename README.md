# 🧰 Cross-Platform Dotfiles

[![License: MIT](https://img.shields.io/badge/License-MIT-1575F9.svg?style=for-the-badge\&logo=open-source-initiative\&logoColor=white)](https://opensource.org/license/mit/)
[![chezmoi](https://img.shields.io/badge/chezmoi-dotfiles-00A0DC?style=for-the-badge\&logo=chezmoi\&logoColor=white)](https://www.chezmoi.io)
[![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge\&logo=ansible\&logoColor=white)](https://www.ansible.com)
[![Documentation](https://img.shields.io/badge/Docs-Docusaurus-25C2A0?style=for-the-badge\&logo=docusaurus\&logoColor=white)](https://docusaurus.io)

---

## 📖 Table of Contents

1. [Modular Dotfiles](#modular-dotfiles)
2. [Design Goals](#✨-design-goals)
3. [Unified Architecture](#🔧-unified-architecture-chezmoi--ansible)
4. [Key Improvements](#🌟-key-improvements)

   * [Cleaner Ansible Structure](#1-cleaner-ansible-structure)
   * [Secure Secret Separation](#2-secure-secret-separation)
   * [Modular Task Layout](#3-modular-task-layout)
5. [Platform Matrix](#🖥-platform-matrix)
6. [Provisioning Flow](#🔁-provisioning-flow)
7. [Secrets Management](#🔐-secrets-management)
8. [Utilities](#🧩-utilities)
9. [Getting Started](#🚀-getting-started)
10. [Governance](#📜-governance)

---

## Modular Dotfiles

A cross-platform, modular dotfiles and system provisioning repository built for **reproducibility**, **security**, and **automation**.

This repository manages:

* Shell configuration
* Developer tooling
* Fonts and terminal setup
* OS-specific provisioning
* Secure secrets handling
* Fully automated bootstrap for new machines

Supported platforms include **Windows**, **macOS**, **Ubuntu**, **Arch Linux**, and **WSL**.

---

## ✨ Design Goals

* Modular by default with no monolithic scripts
* Idempotent and safe to run repeatedly
* Cross-platform using a single repository
* Declarative with state over imperative steps
* Secure with no plaintext secrets
* CI-friendly and automation-ready

---

## 🔧 Unified Architecture: chezmoi + Ansible

* Validated for large-scale environments
* Aligned with SOC 2 and ISO 27001 practices
* Optimized for fast onboarding
* Built using modular, per-platform tasks

Full architecture overview: [ARCHITECTURE.md](./docs/dotfiles/ARCHITECTURE.md)

---

## 🌟 Key Improvements

### 1. Cleaner Ansible Structure

```text
ansible/
└── playbooks/
    ├── ubuntu/
    ├── windows/
    ├── arch/
    ├── darwin/
    └── wsl/
```

Each platform includes its own `requirements.yml` file to isolate dependencies.

### 2. Secure Secret Separation

```text
secrets/
├── chezmoi/          # Dotfile secrets
└── ansible-vault/    # Provisioning secrets
```

Secrets are encrypted and never committed in plaintext.

### 3. Modular Task Layout

```text
playbooks/ubuntu/tasks/
├── apt.yml
├── snap.yml
└── security.yml
```

Tasks are scoped per platform and grouped by responsibility.

---

## 🖥 Platform Matrix

| OS            | Playbook Path                | Dependencies Path                    | Module Examples              |
| ------------- | ---------------------------- | ------------------------------------ | ---------------------------- |
| macOS         | `playbooks/darwin/main.yml`  | `playbooks/darwin/requirements.yml`  | Homebrew, defaults, security |
| Windows       | `playbooks/windows/main.yml` | `playbooks/windows/requirements.yml` | Chocolatey, WinRM, Defender  |
| Ubuntu/Debian | `playbooks/ubuntu/main.yml`  | `playbooks/ubuntu/requirements.yml`  | APT, Snap, kernel            |
| Arch Linux    | `playbooks/arch/main.yml`    | `playbooks/arch/requirements.yml`    | pacman, AUR, systemd         |
| WSL           | `playbooks/wsl/main.yml`     | `playbooks/wsl/requirements.yml`     | Hybrid integration           |

---

## 🔁 Provisioning Flow

1. **Bootstrap**

   * Installs required package managers
   * Installs chezmoi and Ansible

2. **chezmoi**

   * Applies dotfiles
   * Renders OS-specific templates

3. **Ansible**

   * Provisions OS-specific tools
   * Configures security and services

4. **Post-install validation**

   * Verifies tools, fonts, and services

> 🧠 Philosophy: Machines are disposable. Configuration is not.

---

## 🔐 Secrets Management

Secrets are never committed in plaintext.

* **Ansible Vault** for provisioning secrets
* **chezmoi secrets** for dotfiles
* Environment-based overrides supported

```bash
ansible-vault edit secrets/ansible-vault/*.yml
chezmoi secret edit
```

---

## 🧩 Utilities

| Tool     | Description                    |
| -------- | ------------------------------ |
| Taskfile | Cross-platform task runner     |
| direnv   | Automatic environment loader   |
| step-cli | Certificate and PKI management |
| Trivy    | Security scanning              |

---

## 🚀 Getting Started

Follow these steps to bootstrap a new machine with your modular dotfiles setup.

### 1. Clone the Repository

```bash
git clone https://github.com/hetfs/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. Install Required Tools

Ensure you have **Git**, **chezmoi**, and **Ansible** installed:

```bash
# Install chezmoi (cross-platform)
sh -c "$(curl -fsLS get.chezmoi.io)"

# Install Ansible
# macOS (Homebrew)
brew install ansible

# Ubuntu/Debian
sudo apt update && sudo apt install -y ansible

# Arch Linux
sudo pacman -Syu ansible
```

> Windows users should install Ansible via **WSL** or use a provisioning container.

### 3. Initialize chezmoi

```bash
chezmoi init --apply ~/.dotfiles
```

### 4. Run Ansible Playbooks

```bash
# Example for Ubuntu
ansible-playbook playbooks/ubuntu/main.yml

# Example for Windows (PowerShell)
ansible-playbook playbooks/windows/main.yml -i inventories/windows.yml
```

### 5. Post-Installation Validation

* All tools installed
* Fonts and terminal configurations applied
* Services (like WinRM on Windows) running correctly

### Optional: Secrets Setup

```bash
ansible-vault edit secrets/ansible-vault/*.yml
chezmoi secret edit
```

### Quick One-Liner (Full Bootstrap)

```bash
git clone https://github.com/hetfs/dotfiles.git ~/.dotfiles \
&& cd ~/.dotfiles \
&& sh -c "$(curl -fsLS get.chezmoi.io)" \
&& chezmoi init --apply ~/.dotfiles \
&& ansible-playbook playbooks/<platform>/main.yml
```

Replace `<platform>` with your OS (`ubuntu`, `windows`, `darwin`, `arch`, or `wsl`).

---

## 📜 Governance

* License: [MIT](https://opensource.org/license/mit/)
