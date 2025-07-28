---
id: platforms
title: 🌐 Cross-Platform Detection
description: How our framework adapts to Linux, macOS, and Windows systems automatically.
sidebar_position: 4
---

# 🌐 Cross-Platform Detection

One of the core strengths of this framework is its ability to detect and adapt to different platforms—whether you’re on Linux, macOS, or Windows (native or WSL).

## 🔎 Platform Detection Strategy

The framework begins by identifying the operating system and adjusts behavior using platform-specific templates. It leverages `chezmoi`’s built-in templating along with external tools like `uname`, `lsb_release`, or PowerShell environment checks.

## 🧭 Platform Detection Flow

```mermaid
flowchart TD
    A[🔍 Detect Host OS] --> B{OS Type}
    
    B --> |Linux| C[🐧 Identify Distro]
    C --> D{Distro}
    D --> |Arch| D1[🛠️ Use pacman + chezmoi.arch.tmpl]
    D --> |Debian/Ubuntu| D2[🛠️ Use apt + chezmoi.debian.tmpl]
    D --> |Fedora| D3[🛠️ Use dnf + chezmoi.fedora.tmpl]
    D --> |Other| D4[⚠️ Fallback: generic.sh]

    B --> |macOS| E[🍎 Use Homebrew + chezmoi.darwin.tmpl]

    B --> |Windows| F{Environment}
    F --> |WSL| F1[🪟 WSL: use apt + chezmoi.wsl.tmpl]
    F --> |Native| F2[🪟 winget + PowerShell + chezmoi.windows.tmpl]

    B --> |Unknown| Z[❌ Unsupported Platform Warning]
````

## ✅ Why This Matters

* Ensures the correct packages are installed for your platform.
* Prevents breaking changes across systems by applying the right templates.
* Streamlines provisioning and onboarding for contributors.

## 🧰 Templates in Use

| Platform      | Package Manager | Template               |
| ------------- | --------------- | ---------------------- |
| Arch Linux    | `pacman`        | `chezmoi.arch.tmpl`    |
| Ubuntu/Debian | `apt`           | `chezmoi.debian.tmpl`  |
| Fedora        | `dnf`           | `chezmoi.fedora.tmpl`  |
| macOS         | `brew`          | `chezmoi.darwin.tmpl`  |
| Windows       | `winget`        | `chezmoi.windows.tmpl` |
| WSL           | `apt`           | `chezmoi.wsl.tmpl`     |
| Other Linux   | manual fallback | `generic.sh`           |

---

For full source and logic, check the repository:
🔗 [hetfs/dotfiles](https://github.com/hetfs/dotfiles)
