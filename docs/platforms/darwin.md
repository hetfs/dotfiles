---
id: darwin
title: 🍎 macOS Setup
description: Automated configuration and provisioning for macOS devices.
sidebar_position: 4
---

# 🍎 macOS Setup Guide

This guide automates and documents the complete setup for macOS (Darwin) systems using **chezmoi**, **Homebrew**, and optionally **Ansible**.

## 📦 Prerequisites

- macOS 12 Monterey or newer
- Command Line Tools (`xcode-select --install`)
- [chezmoi](https://www.chezmoi.io/)
- [Homebrew](https://brew.sh/)
- Git

## ⚙️ Installation Flow

```bash
/bin/bash -c "$(curl -fsLS get.chezmoi.io)" -- init --apply hetfs
````

Or run the dedicated setup script:

```bash
./bootstrap.sh
```

> ℹ️ `bootstrap.sh` detects Darwin and invokes the `chezmoi.darwin.tmpl` logic with Homebrew integrations.

---

## 🍺 Homebrew Integration

The following tools are installed and managed using Homebrew:

* `git`, `gh`, `zsh`, `fzf`, `bat`, `fd`
* `neovim`, `tmux`, `ripgrep`, `htop`
* `mas` (Mac App Store CLI) — install GUI apps automatically
* `skhd`, `yabai`, and `spacebar` (for tiling window managers)

These are declared in:

```
.chezmoiscripts/darwin/brew-packages.sh
```

---

## 🧪 Optional: Ansible Support

If you enable Ansible integration (`use_ansible = true`), additional provisioning will run after Homebrew setup.

### Example:

```bash
ansible-playbook -i inventory/darwin.yml ansible/bootstrap.yml
```

---

## 📁 Managed dotfiles

macOS-specific dotfiles and preferences include:

* `.zshrc`, `.macos`, `.config/yabai`, `.config/skhd`
* `macos-defaults.sh` to automate `defaults` command settings
* App configuration files (e.g., Hammerspoon, Karabiner)

---

## 🚀 Customization

To customize your install:

* Edit `chezmoi.darwin.tmpl`
* Modify `brew-packages.sh` and `macos-defaults.sh`
* Override or add Ansible roles for GUI app preferences

---

## 🛠️ Troubleshooting

* **Permissions**: Grant Terminal full disk access (System Preferences > Privacy)
* **Homebrew Issues**: Ensure `/opt/homebrew` is in your `$PATH` on Apple Silicon
* **Login Scripts**: Reload shell or reboot after install for all services to apply

---

## 🔗 Links

* 🔗 [chezmoi repo](https://github.com/hetfs/dotfiles)
* 🔗 [Homebrew](https://brew.sh/)
* 🔗 [macOS Defaults Documentation](https://github.com/kevinSuttle/macOS-Defaults)
