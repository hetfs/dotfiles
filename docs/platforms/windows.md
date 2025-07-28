---
id: windows
title: 🪟 Windows Platform Support
description: How the framework behaves on Windows and how to configure automation for Windows endpoints.
sidebar_position: 7
---

# 🪟 Windows Platform Support

Our automation framework supports Windows environments with full scripting capabilities, thanks to [PowerShell Core](https://learn.microsoft.com/powershell/scripting/overview) and [winget](https://learn.microsoft.com/windows/package-manager/winget/). It also adapts behavior for GUI tools, filesystem differences, and shell limitations.

---

## ✅ Requirements for Windows Support

| Requirement             | Notes                                               |
|------------------------|-----------------------------------------------------|
| PowerShell 7+          | Required. Install via `winget install PowerShell`   |
| Git for Windows        | Needed for `chezmoi` and shell usage                |
| winget                 | For managing apps and packages                      |
| Terminal Emulator      | Recommended: [Windows Terminal](https://aka.ms/terminal) or [wezterm](https://wezfurlong.org/wezterm/) |
| Optional: WSL2         | Enables Linux-based automation side-by-side         |

---

## 🧠 Detection Logic for Windows

The platform logic checks:

- `.chezmoi.os == "windows"`
- PowerShell version with `$PSVersionTable.PSVersion`
- Hostname patterns or WSL integration (e.g., `hostname | findstr "wsl"`)

```powershell
if ($IsWindows -and $PSVersionTable.PSVersion.Major -ge 7) {
  Write-Host "Windows automation enabled."
}
````

---

## ⚙️ Windows-Specific Behavior

| Feature           | Behavior on Windows                                            |
| ----------------- | -------------------------------------------------------------- |
| `chezmoi` scripts | Use `.ps1` for Windows, `.sh` for others                       |
| Path handling     | Converts paths to Windows style automatically                  |
| GUI apps          | Enables `notepad`, `winget`, `wezterm`, `kitty` (if installed) |
| Symlinks          | Uses hardlinks or copies if symlinks are restricted            |
| Terminal config   | Supports `PowerShell`, `cmd`, and `Windows Terminal`           |

---

## 🛠 Example: chezmoi Conditional for Windows

```bash
{{ if eq .chezmoi.os "windows" }}
# Add Windows-specific setup or registry tweaks here
{{ end }}
```

Or from PowerShell:

```powershell
if ($env:OS -eq "Windows_NT") {
  # Windows-specific logic
}
```

---

## 📂 Recommended File Structure

```text
.chezmoiscripts/windows/
├── install.ps1
├── configure-registry.ps1
└── setup-terminal.ps1
```

---

## 🧰 Supported Tools via winget

| Tool             | winget Identifier           |
| ---------------- | --------------------------- |
| PowerShell       | `Microsoft.PowerShell`      |
| Git              | `Git.Git`                   |
| WezTerm          | `wez.wezterm`               |
| Neovim           | `Neovim.Neovim`             |
| Windows Terminal | `Microsoft.WindowsTerminal` |
| Starship         | `Starship.Starship`         |

You can include these in your install script:

```powershell
winget install --id Git.Git -e --source winget
winget install --id wez.wezterm -e --source winget
```

---

## 🧪 Testing on Windows

* Run `chezmoi apply` in PowerShell Core
* Validate scripts under `.chezmoiscripts/windows/`
* Confirm that installed tools (wezterm, git, etc.) work from the shell

---

## ⚠️ Windows Gotchas

* ❗ PowerShell execution policy may block scripts. Use:

  ```powershell
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
  ```
* 🪟 Legacy cmd shells may not support ANSI output—prefer PowerShell or Windows Terminal.
* 🔄 Symlink permissions may require admin or developer mode.

---

> 💡 Tip: You can force PowerShell-specific behavior by checking `.chezmoi.shell == "pwsh"` in templates.

---

```

Let me know if you'd like to move on to `darwin.md` (macOS) or `linux.md` next.
```

