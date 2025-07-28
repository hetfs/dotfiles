---
id: linux
title: 🐧 Linux Platform Support
description: How Linux is handled in the cross-platform automation framework.
sidebar_position: 3
---

# 🐧 Linux Platform Support

The framework provides native support for a wide range of Linux distributions. It automatically detects the Linux environment and selects the appropriate installation and configuration strategy.

---

## ✅ Supported Distros

- **Arch Linux** (via `pacman`)
- **Debian/Ubuntu** (via `apt`)
- **Fedora** (via `dnf`)
- **Alpine Linux** (via `apk`)
- **WSL 2** (Windows Subsystem for Linux)

---

## 📦 Linux Provisioning Tools

Depending on the detected distro and shell environment, the following tools are used:

| Tool         | Purpose                                  |
|--------------|------------------------------------------|
| `chezmoi`    | Declarative dotfiles management          |
| `ansible`    | System-level configuration & provisioning|
| `pacman`     | Arch package manager                     |
| `apt`        | Debian/Ubuntu package manager            |
| `dnf`        | Fedora package manager                   |
| `apk`        | Alpine Linux package manager             |

---

## 🛠️ Provisioning Workflow

1. Detect distro using `/etc/os-release`
2. Install `chezmoi` using the appropriate package manager
3. Apply templates like `chezmoi.arch.tmpl`, `chezmoi.debian.tmpl`, etc.
4. Run post-bootstrap `ansible` playbooks if defined
5. Finalize user-level and system-level configurations

---

## 🧠 Mermaid: Advanced Condition Handling in Platform Logic

```mermaid
flowchart TD
    A[Start] --> B[Detect OS: Linux, macOS, Windows]
    B --> C[Check if in CI/CD environment]
    C --> |Yes| D[Use headless mode: auto-approve, no prompts]
    C --> |No| E[Check if interactive shell]

    E --> |Yes| F[Prompt user for custom options]
    E --> |No| G[Use defaults from config]

    D --> H[Determine Provisioning Path]
    F --> H
    G --> H

    H --> I{Privilege Needed?}
    I --> |Yes| J[Check sudo or elevate rights]
    I --> |No| K[Proceed without privilege escalation]

    J --> |Sudo available| L[Run elevated commands]
    J --> |Not available| M[Show error and halt]

    K --> N[Install chezmoi and dependencies]
    L --> N

    N --> O{Platform Type}
    O --> |WSL| P[Use apt + chezmoi.wsl.tmpl]
    O --> |Arch| Q[Use pacman + chezmoi.arch.tmpl]
    O --> |macOS| R[Use brew + chezmoi.darwin.tmpl]
    O --> |Windows Native| S[Use winget + PowerShell]
    O --> |Other| T[Fallback to generic provisioning]

    P --> Z[✔️ Setup Complete]
    Q --> Z
    R --> Z
    S --> Z
    T --> Z
````

---

## 🧪 Notes

* For Arch-based systems, make sure `reflector` and `base-devel` are pre-installed for faster sync.
* `sudo` is required for system-wide installations unless running in root containers.

---

Need a separate `arch.md` or `wsl.md` breakdown? Just say the word!

