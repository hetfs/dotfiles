# 🎨 Fonts Management Guide

This document describes how **fonts are installed, managed, and provisioned** across all supported platforms in the **modular dotfiles repository**. Ensuring consistent font usage is critical for terminal, editor, and IDE setups.

---

## 🔹 Supported Platforms

| Platform            | Notes                                                                                                    |
| ------------------- | -------------------------------------------------------------------------------------------------------- |
| Windows             | Installs fonts to `%LOCALAPPDATA%\Microsoft\Windows\Fonts` or system-wide `C:\Windows\Fonts` if elevated |
| macOS               | Installs fonts to `~/Library/Fonts` or `/Library/Fonts` (requires admin)                                 |
| Linux (Ubuntu/Arch) | Installs fonts in `~/.local/share/fonts` for user-level, or `/usr/share/fonts` for system-wide           |

---

## 🔹 Fonts Included

The repository standardizes on **developer-friendly monospace and coding fonts**:

* FiraCode
* JetBrains Mono
* Source Code Pro
* Hack
* Iosevka
* Mononoki
* Victor Mono
* Inconsolata

> All fonts are installed as **Nerd Fonts patched variants** for terminal glyph support.

---

## 🔹 Installation Process

### 1. Automated via PowerShell / Shell Scripts

* **Windows**:

  * Downloads font `.zip` files from official GitHub releases
  * Extracts to temporary folder
  * Installs fonts to system or user font folder
  * Updates Windows font cache automatically

* **macOS**:

  * Uses `curl` or `wget` to download fonts
  * Extracts and installs via `cp` or `fontutil` commands
  * Refreshes font cache with `fc-cache -fv`

* **Linux**:

  * Downloads fonts to `~/.local/share/fonts`
  * Runs `fc-cache -fv` to update font cache
  * Optional system-wide installation for CI machines

### 2. Template-driven Installation

* Font names and versions are defined in **template files** (`.tmpl`) in chezmoi
* Modular scripts iterate over the list of fonts
* Handles **existing font detection** to avoid duplicates

---

## 🔹 Font Updates & Versioning

* Latest stable releases are automatically fetched from GitHub via scripts
* Existing installations are **detected and skipped** if already up-to-date
* Supports **automatic upgrade** by re-running the installation script

---

## 🔹 User Overrides

* Users can specify **custom fonts or versions** in their local `chezmoi` config
* Template files automatically merge user overrides with defaults
* Example for Windows:

  ```powershell
  $CustomFonts = @("FiraCode Nerd Font", "JetBrainsMono Nerd Font")
  Install-Fonts -Fonts $CustomFonts
  ```

---

## 🔹 CI / Automation Integration

* Fonts are installed automatically during the **bootstrap process**
* CI builds for Linux/macOS/Windows ensure fonts are **present and usable** for terminal and editor tests
* Font verification is part of the **post-install validation** workflow

---

## 🔹 Troubleshooting

| Issue                          | Solution                                                             |
| ------------------------------ | -------------------------------------------------------------------- |
| Font not appearing in terminal | Check font cache (`fc-cache -fv` on Linux/macOS, restart on Windows) |
| Duplicate fonts                | Remove older version from user/system font directories               |
| Installation fails on Windows  | Run PowerShell as Administrator                                      |
| Missing glyphs in Nerd Fonts   | Verify correct Nerd Font variant downloaded                          |

---

## 🔹 References

* [Nerd Fonts GitHub](https://github.com/ryanoasis/nerd-fonts)
* [Windows Fonts Folder](https://docs.microsoft.com/en-us/windows/win32/uxguide/fonts)
* [Linux Font Management](https://wiki.archlinux.org/title/fonts)
* [macOS Font Book](https://support.apple.com/en-us/HT201749)

---

This **modular font management** ensures that your terminals, editors, and IDEs have **consistent, developer-friendly typography** across all platforms.
