---
id: chezmoi
title: 🧰 Chezmoi Setup
description: Declarative, reproducible dotfiles management with Chezmoi and Git.
sidebar_position: 1
---

# 🧰 Chezmoi Dotfiles Management

> Your developer environment, version-controlled, portable, and secure.

[**Chezmoi**](https://www.chezmoi.io) is a cross-platform dotfiles manager that empowers you to manage your home directory declaratively, reproducibly, and securely using Git and modern tooling.

This documentation explains how the [`hetfs/dotfiles`](https://github.com/hetfs/dotfiles) project uses Chezmoi to automate and streamline configuration across **macOS**, **Linux**, **WSL**, and **Windows** environments.

---

## 🎯 Why Chezmoi?

- ✅ **Cross-platform**: macOS, Linux, Windows, and WSL
- 🔐 **Secure secrets management**: Supports GPG, Bitwarden, Vault, 1Password
- ⚙️ **Modular configuration**: OS-specific logic and templates
- 💾 **Offline-first**: Git-based storage, fully local workflows
- 🔁 **Repeatable setup**: Reprovision environments with one command
- 🧩 **Extensible**: Add hooks, scripts, and platform-aware logic

---

## 🚀 Getting Started

### 1. Install Chezmoi

Refer to the [official instructions](https://www.chezmoi.io/install/) or use one of the quick installers below.

#### Linux/macOS

```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
````

#### Windows (with winget)

```powershell
winget install --id=twp.chezmoi
```

---

### 2. Initialize from Dotfiles Repo

To clone and apply configuration immediately:

```bash
chezmoi init --apply https://github.com/hetfs/dotfiles.git
```

Or to review before applying:

```bash
chezmoi init https://github.com/hetfs/dotfiles.git
chezmoi apply
```

---

## 🧠 Project Structure

Here's a simplified view of the repo structure used in [`hetfs/dotfiles`](https://github.com/hetfs/dotfiles):

```plaintext
dotfiles/
├── .chezmoiroot
├── .chezmoi.yaml.tmpl
├── .chezmoiscripts/
│   ├── linux/
│   ├── darwin/
│   └── windows/
├── dot_config/
│   ├── nvim/
│   ├── starship.toml
│   └── zsh/
├── private_dot_gitconfig.tmpl
└── ...
```

* 🧠 `*.tmpl`: Uses [Go template syntax](https://pkg.go.dev/text/template) for dynamic rendering.
* 💡 `.chezmoiscripts`: Platform-aware scripts for provisioning hooks.
* ⚙️ `dot_config/`: User configuration for tools like Neovim, Starship, and Zsh.

---

## 🧪 Apply or Test Changes

Use the following commands to test or apply updates:

```bash
chezmoi diff         # Show pending changes
chezmoi apply        # Apply changes
chezmoi apply --dry-run  # Simulate without applying
```

Run this regularly to keep your system in sync.

---

## 🔐 Secrets Management

Chezmoi integrates with several secrets managers:

| Backend       | Link                                             |
| ------------- | ------------------------------------------------ |
| 1Password CLI | [Docs](https://developer.1password.com/docs/cli) |
| Bitwarden     | [bitwarden.com](https://bitwarden.com)           |
| GPG           | [gnupg.org](https://gnupg.org)                   |
| Vault         | [vaultproject.io](https://www.vaultproject.io)   |

In templates, use secrets like this:

```tmpl
{{ (chezmoi.secret "api-key-prod") }}
```

Configure secrets in `.chezmoi.yaml.tmpl`.

---

## 🧩 Hooks & Automation Scripts

Automate installation steps using lifecycle scripts:

```bash
.chezmoiscripts/{os}/run_before_01_install.sh
.chezmoiscripts/{os}/run_after_99_cleanup.sh
```

Supported hook formats:

* `run_before_*`
* `run_after_*`
* `run_once_before_*`
* `run_once_after_*`

Use these to install packages, configure apps, or set environment variables automatically.

---

## ➕ Add Your Own Dotfiles

Want to track your current dotfiles?

```bash
chezmoi add ~/.bashrc
chezmoi add ~/.config/starship.toml
chezmoi apply
```

This syncs the file to the Git-managed configuration and applies it immediately.

---

## 📁 Repository

Source: [`hetfs/dotfiles`](https://github.com/hetfs/dotfiles)

GitHub: 👉 [https://github.com/hetfs/dotfiles](https://github.com/hetfs/dotfiles)

---

## 📚 Helpful References

* [Chezmoi Documentation](https://www.chezmoi.io/docs/)
* [Chezmoi CLI Reference](https://www.chezmoi.io/reference/)
* [Templating with Go](https://www.chezmoi.io/docs/templating/)
* [Using Secrets](https://www.chezmoi.io/user-guide/secrets/)

---

## 🛠 Troubleshooting

Run `chezmoi doctor` to validate your setup:

```bash
chezmoi doctor
```

This checks for missing dependencies, permissions issues, and more.

---

> ⚡ **Pro tip**: Automate your environment setup by combining Chezmoi with tools like Ansible, direnv, and task runners for a fully portable developer experience.
