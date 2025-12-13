# 🧩 Plugins & Extensions

This document details **all plugins and extensions** managed in the modular dotfiles repository. It covers **shell, terminal, and editor plugins**, ensuring consistent behavior across Windows, macOS, Linux, and WSL.

---

## 🔹 Shell & Prompt Plugins

| Tool                        | Plugin                      | Purpose                          | Notes                                                    |
| --------------------------- | --------------------------- | -------------------------------- | -------------------------------------------------------- |
| **Zsh / Bash / PowerShell** | **Starship**                | Cross-shell prompt               | Uses dotfiles templates for unified prompt configuration |
| **Bash / Zsh**              | **fzf-tab**                 | Tab completion enhancement       | Optional, loaded if `fzf` is present                     |
| **Bash / Zsh**              | **zsh-autosuggestions**     | Command suggestions              | Requires Zsh                                             |
| **Bash / Zsh**              | **zsh-syntax-highlighting** | Syntax highlight for commands    | Loaded after autosuggestions                             |
| **PowerShell 7+**           | **PSReadLine**              | Command-line editing & history   | Included in PS7+                                         |
| **Bash / Zsh / PowerShell** | **direnv**                  | Auto environment variable loader | Loads `.envrc` files per directory                       |

---

## 🔹 Terminal & Tmux Plugins

| Tool     | Plugin                        | Purpose                             |
| -------- | ----------------------------- | ----------------------------------- |
| **tmux** | **tpm (Tmux Plugin Manager)** | Manages tmux plugins                |
| **tmux** | **tmux-sensible**             | Sensible defaults for tmux          |
| **tmux** | **tmux-resurrect**            | Persist & restore sessions          |
| **tmux** | **tmux-continuum**            | Automatic tmux session save/restore |

> tmux plugins are automatically installed via bootstrap scripts and configured in `.tmux.conf`.

---

## 🔹 Editor Plugins

### Neovim

| Category     | Plugin              | Purpose                            |
| ------------ | ------------------- | ---------------------------------- |
| LSP / IDE    | **nvim-lspconfig**  | Language server configuration      |
| LSP / IDE    | **mason.nvim**      | Manage LSP servers and DAPs        |
| Completion   | **nvim-cmp**        | Autocompletion engine              |
| Snippets     | **LuaSnip**         | Snippet engine                     |
| Syntax       | **nvim-treesitter** | Fast syntax highlighting           |
| Git          | **gitsigns.nvim**   | Git signs in gutter                |
| UI           | **lualine.nvim**    | Status line                        |
| Fuzzy finder | **telescope.nvim**  | File and command search            |
| Debugging    | **nvim-dap**        | Debug Adapter Protocol integration |

> All Neovim plugins are managed via **lazy.nvim** for fast startup and modular loading.

### Vim (Legacy Support)

| Plugin           | Purpose                |
| ---------------- | ---------------------- |
| **vim-plug**     | Plugin manager         |
| **NERDTree**     | File explorer          |
| **vim-airline**  | Status bar enhancement |
| **vim-fugitive** | Git integration        |

---

## 🔹 VS Code Extensions

| Extension                                 | Purpose                |
| ----------------------------------------- | ---------------------- |
| **ms-vscode.cpptools**                    | C/C++ support          |
| **ms-python.python**                      | Python support         |
| **esbenp.prettier-vscode**                | Code formatting        |
| **eamodio.gitlens**                       | Git insights           |
| **ms-vscode.powershell**                  | PowerShell integration |
| **streetsidesoftware.code-spell-checker** | Spelling & linting     |
| **dbaeumer.vscode-eslint**                | JS/TS linting          |

> Installed automatically via Ansible tasks or `code --install-extension` commands.

---

## 🔹 CI / Automation Plugin Integration

* Plugins are **idempotently installed** via dotfiles bootstrap scripts
* Lazy-loaded where possible to **reduce startup time**
* Version pinning ensures **reproducibility across machines**
* Scripts validate plugin installation after bootstrap to prevent broken setups

---

## 🔹 Customization & Overrides

* Plugin configurations are **templated per OS** and can be overridden via chezmoi variables
* Neovim: `~/.config/nvim/lua/config/*.lua`
* Starship: `~/.config/starship.toml`
* Tmux: `~/.tmux.conf.local` (overrides `.tmux.conf`)
* PowerShell: `Microsoft.PowerShell_profile.ps1`

> All customizations are **modular** and **safe to update or override** without breaking base configurations.

---

## 🔹 References

* [Starship](https://starship.rs/)
* [fzf](https://github.com/junegunn/fzf)
* [Neovim Plugins](https://github.com/nvim-lua/kickstart.nvim)
* [tmux Plugins](https://github.com/tmux-plugins)
* [VS Code Marketplace](https://marketplace.visualstudio.com/)

---

This **PLUGINS.md** ensures developers have **a clear, reproducible view of all enhancements** applied to shells, terminals, and editors across platforms.
