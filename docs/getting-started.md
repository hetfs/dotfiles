---
id: getting-started
title: 🚀 Getting Started
sidebar_position: 3
description: Bootstrap your system using chezmoi and Ansible. Declarative, secure, and cross-platform.
---

# 🚀 Getting Started

Welcome! This guide walks you through setting up a fully automated development environment using [**chezmoi**](https://www.chezmoi.io) and [**Ansible**](https://www.ansible.com). Everything is declarative, secure, and version-controlled across platforms.

> 🛠️ Source repo: [github.com/hetfs/dotfiles](https://github.com/hetfs/dotfiles)

---

## 🧰 Prerequisites

Make sure these tools are installed before continuing:

| Tool | Purpose | Install |
|------|---------|---------|
| [chezmoi](https://www.chezmoi.io) | Dotfile and config management | [Install Guide →](https://www.chezmoi.io/install/) |
| [Ansible](https://www.ansible.com) | System provisioning | [Install Guide →](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) |
| [Git](https://git-scm.com) | Version control system | Preinstalled or install via `apt`, `brew`, or `winget` |
| *(Optional)* [1Password CLI](https://developer.1password.com/docs/cli/), [age](https://github.com/FiloSottile/age), [sops](https://github.com/mozilla/sops) | Secrets management | Used in secure provisioning workflows |

---

## 📦 Step 1: Install chezmoi

Install `chezmoi` using the official script:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
````

Verify the installation:

```bash
chezmoi --version
```

---

## 🧩 Step 2: Apply Your Dotfiles

Initialize your environment from the dotfiles repo:

```bash
chezmoi init --apply https://github.com/hetfs/dotfiles
```

What this does:

* Clones the repository
* Applies templates and config files
* Adapts settings to your OS, hostname, and user
* Decrypts secrets (if configured)

> 💡 Your setup auto-adjusts per platform using conditional logic and templates.

---

## ⚙️ Step 3: Provision with Ansible

Once chezmoi completes setup, use Ansible to install packages and configure your system:

```bash
ansible-playbook ~/.config/refresh.yml
```

This step covers:

* 🔧 Native package installation (`APT`, `Homebrew`, `Winget`, `pacman`)
* 🔐 Secrets injection from vaults (chezmoi, Ansible Vault, sops, age)
* ⚙️ System configuration and hardening

---

## 🔁 Optional: One-Liner Bootstrap

Prefer GitOps-style setup with a single command? Use a script like this:

```bash
#!/bin/bash
chezmoi init --apply https://github.com/hetfs/dotfiles
ansible-playbook ~/.config/refresh.yml
```

Make it executable:

```bash
chmod +x ./bootstrap.sh
```

You can run it on any new machine for full, repeatable automation.

---

## ✅ What’s Next?

Explore other parts of the framework:

* 🧩 [Dotfile Management →](./chezmoi/chezmoi.md)
* ⚙️ [System Provisioning →](./ansible/ansible.md)
* 🔐 [Secrets & Security →](./security.md)
* 💻 [Platform Matrix →](./platforms.md)

---

## 🧠 Tips & Best Practices

* Use `chezmoi diff` before applying to preview changes.
* Leverage template conditionals to adapt per user, OS, or architecture.
* Use Ansible roles to modularize tasks and simplify maintenance.
* Keep secrets encrypted and commit-safe using `sops`, `age`, or `1Password`.

---

## 📚 Documentation & Tools

* 📘 [chezmoi Docs](https://www.chezmoi.io/docs/)
* ⚙️ [Ansible Docs](https://docs.ansible.com/)
* 🔐 [1Password CLI Docs](https://developer.1password.com/docs/cli/)
* 🔒 [sops GitHub](https://github.com/mozilla/sops)
* 🔑 [age GitHub](https://github.com/FiloSottile/age)

---

> **Fast to set up. Easy to maintain. Designed for real-world developer workflows.**
