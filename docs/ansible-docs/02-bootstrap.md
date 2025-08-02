---
id: 02-bootstrap
title: 🚀 Bootstrapping Your System
description: Step-by-step guide to prepare your system for Ansible automation.
sidebar_position: 2
---

# 🚀 Bootstrapping Your System

Before you can run full Ansible playbooks, your system needs to be **bootstrapped**. Bootstrapping means installing the essential tools required to enable automated configuration and deployment.

---

## 🧰 What Bootstrapping Sets Up

The bootstrap process prepares your system with:

- Python (required for Ansible)
- `ansible` installed via `pipx` or a package manager
- Git (used for dotfiles, chezmoi, and Ansible repositories)
- `sudo` and remote access configuration
- SSH key creation and authorization
- Optional tools like:
  - `chezmoi` (dotfiles manager)
  - `pipx` (Python CLI tool manager)
  - `brew` (macOS/Linux package manager)
  - `winget` (Windows package manager)

> ✅ These tools form the foundation of your automation stack.

---

## 🖥️ Supported Operating Systems

| OS       | Method           | Notes                                         |
|----------|------------------|-----------------------------------------------|
| **Linux**    | Bash or Ansible   | Supports Arch, Ubuntu, RHEL, Fedora            |
| **macOS**    | Manual + Script   | Requires Xcode CLI tools via `xcode-select`    |
| **Windows**  | PowerShell        | Via WinRM or local Admin + OpenSSH             |

---

## 💻 Linux Bootstrapping

To bootstrap a Linux system:

```bash
./scripts/bootstrap-linux.sh
````

What it installs:

* Python 3, `pip`, and `pipx`
* `ansible`, `git`, `chezmoi`
* SSH keys and basic user setup
* Your dotfiles with `chezmoi`

> 🧪 Works on most Debian-, Arch-, and RHEL-based distributions.

---

## 🍏 macOS Bootstrapping

For macOS:

```bash
xcode-select --install
brew install chezmoi pipx
pipx install ansible
chezmoi init --apply hetfs
```

Optional post-bootstrap:

```bash
chezmoi apply
ansible-playbook playbooks/mac.yml
```

> 💡 `brew` simplifies tool installation across Apple Silicon and Intel Macs.

---

## 🪟 Windows Bootstrapping

From an **elevated PowerShell** prompt:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
iwr -useb https://raw.githubusercontent.com/hetfs/dotfiles/main/scripts/bootstrap-windows.ps1 | iex
```

What it installs:

* `winget` or Chocolatey
* Python, pip, `pipx`, `ansible`
* Git, `chezmoi`, OpenSSH
* SSH key and user config

> ⚠️ Requires admin rights and PowerShell 5.1+.

---

## 🧠 Why Bootstrapping Matters

Bootstrapping builds a clean, predictable foundation for automation:

* Ensures `ansible` and `chezmoi` are present
* Reduces playbook failures caused by missing dependencies
* Standardizes environments across laptops, servers, and VMs

---

## 📁 Scripts Directory Overview

All bootstrap scripts live in:

```bash
scripts/
├── bootstrap-linux.sh
├── bootstrap-macos.sh
└── bootstrap-windows.ps1
```

They’re reusable in:

* CI pipelines
* Remote builds
* Live provisioning demos

> 📦 Treat them as your automation entry point.

---

## ⏭️ What’s Next?

Once bootstrapping completes, run your playbooks:

```bash
ansible-playbook playbooks/linux.yml -K  # For Linux
ansible-playbook playbooks/mac.yml       # For macOS
```

Or trigger via chezmoi:

```bash
chezmoi apply
```

You’re now ready to let Ansible take over the heavy lifting! 🛠️
