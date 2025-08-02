---
id: intro
title: 🧰 Introduction
sidebar_position: 1
description: Cross-platform dotfiles automation powered by chezmoi and Ansible. Declarative setup. Developer-focused. Secure by default.
---

# 🧰 Cross-Platform Dotfiles Automation

A unified, secure, and declarative system for managing dotfiles, provisioning environments, and enforcing configuration policies across macOS, Windows, Linux, Arch, and WSL.
Powered by [chezmoi](https://www.chezmoi.io) and [Ansible](https://www.ansible.com), this setup is designed with **developer experience**, **compliance**, and **repeatable automation** in mind ensuring a consistent environment everywhere you work.

---

## 💡 Why Use This System?

Whether you're a solo developer, a platform engineer, or managing a fleet of systems, this setup enables:

- ⚡️ Rapid onboarding across devices
- 🔐 Secure, encrypted secrets and credentials
- 📦 Platform-aware provisioning and package installs
- 🧠 Consistent configuration with declarative logic
- 📘 Self-documenting code and architecture (powered by [Docusaurus](https://docusaurus.io))

---

## 🧰 Required Toolchain

| Tool         | Purpose                            | Install Guide                                                  | Project Role              |
|--------------|------------------------------------|----------------------------------------------------------------|---------------------------|
| **chezmoi**  | Dotfile management                 | [chezmoi.io/install](https://www.chezmoi.io/install/)          | Core dotfile templating   |
| **Ansible**  | System provisioning                | [Ansible Docs](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) | Runs provisioning tasks   |
| **Git**      | Version control                    | Pre-installed or from package manager                          | Required for cloning      |
| **Python**   | Ansible runtime                    | `apt`, `brew`, etc.                                            | Dependency for Ansible    |

---

## 🧱 Architecture Overview

| Layer      | Tool/Tech                                | Description                                     |
|------------|-------------------------------------------|-------------------------------------------------|
| 🧩 Dotfiles | [chezmoi](https://www.chezmoi.io)         | Templated config with OS/distro logic           |
| ⚙️ Provisioning | [Ansible](https://www.ansible.com)     | Declarative OS configuration                    |
| 📦 Packages | APT, Homebrew, Winget, pacman, paru       | Native OS-specific package managers             |
| 🔐 Secrets  | `chezmoi secrets`, `ansible-vault`, `sops`, `age` | Secure secrets storage                     |
| 📚 Docs     | [Docusaurus](https://docusaurus.io)       | Developer documentation                         |
| 🔁 GitOps   | `ansible-pull`, `bootstrap.sh`            | Git-driven provisioning and CI integration      |

---

## 🌍 Platform Matrix

| Platform       | Detection Logic                    | Role     | Package Manager       |
|----------------|-------------------------------------|----------|------------------------|
| **Windows**    | `ansible_os_family == "Windows"`    | `windows`| Winget                 |
| **WSL**        | Kernel + distro check               | `wsl`    | APT (via WSL)          |
| **macOS**      | `ansible_os_family == "Darwin"`     | `macos`  | Homebrew               |
| **Debian/Ubuntu** | `ansible_distribution` matches    | `debian` | APT                    |
| **Arch Linux** | `ansible_distribution == "Archlinux"`| `arch`   | pacman, paru           |

✅ **WSL** is treated as a first-class citizen with Windows sync support.

---

## 🚀 Installation Workflow

### Quick Start

```bash
chezmoi init https://github.com/hetfs/dotfiles --apply
chezmoi apply
ansible-playbook ansible/playbooks/darwin/main.yml
````

---

## 📦 Platform-Specific Setup

| Platform   | Key File                             | Notes                    |
| ---------- | ------------------------------------ | ------------------------ |
| 🪟 Windows | `ansible/playbooks/windows/main.yml` | Run in Admin PowerShell  |
| 💠 WSL     | `ansible/playbooks/wsl/main.yml`     | WSL-native provisioning  |
| 🍏 macOS   | `ansible/playbooks/darwin/main.yml`  | Requires Xcode CLI tools |
| 🐧 Ubuntu  | `ansible/playbooks/ubuntu/main.yml`  | Uses APT and Snap        |
| 🅰️ Arch    | `ansible/playbooks/arch/main.yml`    | Supports pacman and AUR  |

---

## 🗂️ Repository Structure

```bash
dotfiles/
├── .chezmoi.toml                # Chezmoi config
├── .chezmoiignore               # Ignore list
│
├── .chezmoitemplates/           # Templated files/scripts
│   ├── run_once_install.sh.tmpl
│   └── run_once_install.ps1.tmpl
│
├── .chezmoiscripts/             # Platform scripts
│   ├── linux/ | windows/ | darwin/
│
├── ansible/
│   ├── inventories/             # Environment inventories
│   ├── playbooks/               # OS-specific provisioning
│   ├── roles/                   # Modular reusable roles
│   ├── ansible.cfg              # Ansible config
│   ├── .ansible-lint            # Ansible linting rules
│   └── .yamllint                # YAML linting rules
```

See full [Architecture Overview](./dev/01-architecture.md)

---

## 🔐 Secrets Handling

### With Chezmoi GPG

```bash
gpg --full-generate-key
chezmoi --gpg-recipient YOUR_ID add --encrypt ~/.ssh/id_rsa
```

### With Ansible Vault

```bash
echo "vault-pass" > ~/.vault_pass
chmod 600 ~/.vault_pass
ansible-vault encrypt ansible/config/host_vars/prod-server.yml
```

---

## 🧪 Quality Assurance

```bash
pip install -r ansible/test/requirements.txt
cd ansible
ansible-lint playbooks/
yamllint .
molecule test
```

---

## 🚦 Preflight Checklist

| Task              | Command                           | Status      |
| ----------------- | --------------------------------- | ----------- |
| Health Check      | `chezmoi doctor`                  | ✅ OK        |
| Lint Playbooks    | `ansible-playbook --syntax-check` | ✅ OK        |
| Ping Targets      | `ansible -m ping all`             | ✅ Reachable |
| Secret Validation | `vault audit secrets/`            | ✅ Verified  |

---

## 🧠 Design Philosophy

> **“Infrastructure as Code for Developer Environments.”**

* Reproducible: One command setup, anywhere
* Secure: Encrypted secrets and role-based separation
* Declarative: You define what, not how

---

## 📚 Further Reading

* [Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* [Install Chezmoi](https://www.chezmoi.io/install/)
* [Docusaurus.io](https://docusaurus.io)
* [https://github.com/hetfs/dotfiles/issues](https://github.com/hetfs/dotfiles/issues)
