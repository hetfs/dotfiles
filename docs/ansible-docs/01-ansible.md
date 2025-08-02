---
id: 01-ansible
title: 🔧 Ansible Automation
description: Automate configuration, deployment, and secrets across Linux, Windows, and macOS.
sidebar_position: 1
---

# 🔧 Ansible Automation

[![Ansible](https://img.shields.io/badge/Ansible-Tool-blue?logo=ansible)](https://www.ansible.com/)
[![License](https://img.shields.io/github/license/hetfs/dotfiles)](https://github.com/hetfs/dotfiles/blob/main/LICENSE)
[![Stars](https://img.shields.io/github/stars/hetfs/dotfiles?style=social)](https://github.com/hetfs/dotfiles)

**Ansible** is a powerful, agentless automation tool that connects over [SSH](https://docs.ansible.com/ansible-core/devel/collections/ansible/builtin/ssh_connection.html) (Linux/macOS) or [WinRM](https://docs.ansible.com/ansible/latest/user_guide/windows_winrm.html) (Windows). It configures systems, installs packages, and orchestrates workflows using **simple YAML playbooks**.

---

## 🚀 Source Repository

🔗 [**hetfs/dotfiles** – View on GitHub](https://github.com/hetfs/dotfiles)

This repository includes reusable Ansible playbooks, inventories, and roles that automate cross-platform environments.

---

## 📦 What’s Automated

- ✅ Linux systems: Arch, Ubuntu, RHEL
- 🍏 macOS setup via [Homebrew](https://brew.sh/)
- 🪟 Windows provisioning with:
  - [Chocolatey](https://chocolatey.org/)
  - [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/)
  - [PowerShell DSC](https://learn.microsoft.com/en-us/powershell/dsc/)
- 🔐 Secrets and dotfiles pulled via [`chezmoi`](../chezmoi/chezmoi.md)

---

## 🔐 Secrets Management

Secrets are encrypted and version-controlled securely using:

- [🔐 ansible-vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
- Git-ignored encrypted files under `vault/`
- Optional integration with:
  - [1Password CLI](https://developer.1password.com/docs/cli/)
  - [Bitwarden CLI](https://bitwarden.com/help/cli/)
  - [GPG](https://gnupg.org/)

---

## 📁 Directory Layout

```bash
ansible/
├── inventory/
│   ├── hosts.yml
│   └── group_vars/
├── playbooks/
│   ├── linux.yml
│   ├── mac.yml
│   └── windows.yml
├── roles/
│   ├── common/
│   ├── users/
│   └── devtools/
└── vault/
````

* `inventory/`: Host/group definitions and variables
* `playbooks/`: OS-specific automation tasks
* `roles/`: Modular tasks reusable across systems
* `vault/`: Encrypted secrets not tracked by Git

---

## 🔄 Tool Integrations

* 🧰 **[chezmoi](../chezmoi/chezmoi.md)** – Manages dotfiles and templates used by playbooks
* 🧪 **[Molecule](https://molecule.readthedocs.io/en/latest/)** – Tests Ansible roles in containers or VMs
* 🚀 **[GitHub Actions](https://github.com/features/actions)** – Automates CI/CD tasks using Ansible workflows

---

## 🧠 Getting Started

Follow these steps to provision a system:

### 1. Clone the repo

```bash
git clone https://github.com/hetfs/dotfiles
cd dotfiles/ansible
```

### 2. Set up the inventory

```bash
cp inventory/hosts.example.yml inventory/hosts.yml
```

Edit `inventory/hosts.yml` to define your systems.

### 3. Run your first playbook

```bash
ansible-playbook playbooks/linux.yml -i inventory/hosts.yml
```

Use `--ask-vault-pass` if using `ansible-vault`.

---

## 📚 Further Reading

* 📖 [Ansible Docs](https://docs.ansible.com/)
* ✅ [Best Practices Guide](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
* 🌍 [Ansible Galaxy Collections](https://galaxy.ansible.com/)
* 📚 [Cross-Platform Dotfiles with chezmoi](../chezmoi/01-chezmoi.md)
