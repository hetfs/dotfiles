# 🛠 Developer & Terminal Tools Guide

This document describes **all developer tooling, terminal enhancements, and automation utilities** managed by the modular dotfiles repository. These tools are installed consistently across **Windows, macOS, Linux, and WSL** for reproducible environments.

---

## 🔹 Supported Platforms

| Platform            | Notes                                                   |
| ------------------- | ------------------------------------------------------- |
| Windows             | Installs via Chocolatey, Scoop, or direct binaries      |
| macOS               | Installs via Homebrew or direct binaries                |
| Linux (Ubuntu/Arch) | Installs via APT, pacman, Snap, or direct binaries      |
| WSL                 | Uses Linux package managers or Windows interoperability |

---

## 🔹 Core Tools Included

| Tool                | Purpose                                                   |
| ------------------- | --------------------------------------------------------- |
| **Git**             | Version control and repository management                 |
| **Neovim**          | Modern Vim editor with modular config support             |
| **VS Code**         | GUI-based code editor, integrated with dotfiles templates |
| **Starship**        | Cross-shell prompt for Zsh, Bash, PowerShell              |
| **FZF**             | Command-line fuzzy finder                                 |
| **Bat**             | Cat clone with syntax highlighting                        |
| **Delta**           | Git diff viewer                                           |
| **Node.js / npm**   | JavaScript runtime & package management                   |
| **trash-cli**       | Safe CLI trash management (cross-platform)                |
| **ripgrep**         | Fast text search in files                                 |
| **htop / glances**  | Interactive process viewers                               |
| **tmux**            | Terminal multiplexer                                      |
| **Taskfile / Task** | Task runner for automation scripts                        |
| **direnv**          | Auto environment variable loader                          |
| **step-cli**        | Certificate management                                    |
| **Trivy**           | Security scanning for container images and filesystem     |

> Additional platform-specific tools are installed via **Ansible playbooks** per OS.

---

## 🔹 Installation Process

### 1. Package Manager Driven

* **Windows:** Chocolatey, Scoop, or direct installer automation
* **macOS:** Homebrew automation via scripts
* **Linux:** Native package managers (APT, pacman), Snap for optional tools
* **WSL:** Linux package managers or Windows interoperability

### 2. Idempotent Installation

* Tools are **detected before installation** to avoid duplicates
* Scripts handle version pinning and automatic updates
* CI pipelines validate tool availability post-install

### 3. Modular Task Integration

* Tools are defined in **platform-specific Ansible tasks**:

  ```text
  playbooks/windows/tasks/chocolatey.yml
  playbooks/ubuntu/tasks/apt.yml
  playbooks/darwin/tasks/homebrew.yml
  playbooks/arch/tasks/pacman.yml
  ```
* Shell scripts wrap around tool installation for **interactive or non-interactive bootstrapping**

---

## 🔹 Configuration & Customization

* Tools like **Neovim, Starship, Git, tmux** are pre-configured via **dotfiles templates**
* Users can override defaults by editing **chezmoi template variables**:

  ```bash
  chezmoi edit ~/.config/starship.toml
  chezmoi edit ~/.gitconfig
  ```
* Themes, prompts, and editor plugins are modular and **cross-platform aware**

---

## 🔹 CI / Automation Integration

* During bootstrap, all tools are automatically installed and validated
* **Version checks** are performed to ensure reproducibility across environments
* **Fallback mechanisms** ensure that if a tool fails to install, the process continues without breaking other setups

---

## 🔹 Troubleshooting

| Issue                  | Solution                                                                                                      |
| ---------------------- | ------------------------------------------------------------------------------------------------------------- |
| Tool not found         | Verify installation logs; rerun bootstrap scripts                                                             |
| Version mismatch       | Remove old version and rerun scripts with version pinning                                                     |
| Editor plugins missing | Ensure dotfiles templates are rendered and Neovim/Vim plugins are installed (`:PackerSync` or `:PlugInstall`) |
| Command not recognized | Ensure shell path is reloaded or `source ~/.bashrc` / `source ~/.zshrc` executed                              |

---

## 🔹 References

* [Chocolatey](https://chocolatey.org/)
* [Homebrew](https://brew.sh/)
* [Neovim](https://neovim.io/)
* [Starship](https://starship.rs/)
* [FZF](https://github.com/junegunn/fzf)
* [Bat](https://github.com/sharkdp/bat)
* [Delta](https://github.com/dandavison/delta)
* [Taskfile](https://taskfile.dev/)
* [Trivy](https://aquasecurity.github.io/trivy/)

---

This **TOOLS.md** ensures all developers using the modular dotfiles repository have **consistent tooling, versioning, and configuration** across platforms, making onboarding and CI/CD automation seamless.

