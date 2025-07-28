---
id: intro
title: 🧰 Overview
sidebar_position: 1
description: A cross-platform automation framework powered by chezmoi and Ansible. Declarative setup. Developer-focused. Secure by default.
---

# 🧰 Cross-Platform Automation Framework

Welcome to the **Cross-Platform Automation Framework**—a unified system for managing dotfiles, provisioning systems, and enforcing security policies across macOS, Windows, Linux, and WSL environments.

Built with [**chezmoi**](https://www.chezmoi.io) and [**Ansible**](https://www.ansible.com), this framework focuses on **developer experience**, **compliance**, and **repeatable automation**—delivering consistency across every platform you touch.

---

## 💡 Why Use This Framework?

Whether you're a solo developer, part of a platform engineering team, or managing fleets of systems at scale, this framework helps you:

- 🚀 Bootstrap new machines in minutes—repeatably and reliably  
- 🔒 Stay aligned with SOC 2 and ISO 27001 best practices  
- 🧠 Adapt your configuration per OS, architecture, or user role  
- 📚 Maintain living documentation via [**Docusaurus**](https://docusaurus.io)

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

## 🚀 Quickstart

### 1. Install `chezmoi`

```bash
sh -c "$(curl -fsLS https://chezmoi.io/get)"
```

### 2. Initialize your dotfiles

```bash
chezmoi init --apply https://github.com/YOUR_REPO
```

### 3. Run provisioning

```bash
ansible-playbook ~/.config/refresh.yml
```

📖 See the [Getting Started Guide](./getting-started.md) for a full walkthrough.

---

## 🧠 Core Philosophy

> **Declarative automation meets adaptive personalization.**

This framework follows **GitOps** and **conditional logic** principles. Every system becomes:

* Reproducible
* Secure by default
* Personalized without manual edits

---

## 🔗 What's Next?

Explore the rest of the documentation:

* 📘 [Getting Started](./getting-started.md)
* 🛠️ [chezmoi Dotfile Management](./chezmoi.md)
* ⚙️ [Ansible System Provisioning](./ansible.md)
* 🔐 [Secrets & Compliance](./security.md)
* 💻 [Supported Platforms](./platforms.md)
* 🧪 [Testing & Validation](./testing.md)

---

> **Built for scale. Secured for compliance. Tuned for developers.**
