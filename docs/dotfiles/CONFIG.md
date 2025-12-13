# ⚙️ Configuration Reference

This document explains all **user-configurable options**, environment variables, and template overrides used across the **modular dotfiles repository**. It ensures machines can be **fully provisioned, reproducible, and customized per user or environment**.

---

## 🔹 Configuration Principles

1. **Modular** – Each platform or tool has its own config file.
2. **Idempotent** – Changes can be applied multiple times safely.
3. **Cross-platform** – Options work on Windows, macOS, Linux, and WSL.
4. **Template-driven** – Variables can be overridden using **chezmoi templates** or **Ansible vars**.
5. **Secure** – Secrets are never stored in plain text. Use **Ansible Vault** or **chezmoi secrets**.

---

## 🔹 chezmoi Configuration

### Directory Structure

```text
~/.config/chezmoi/
├── chezmoi.toml          # Main configuration
├── templates/            # Template overrides for dotfiles
├── data/                 # Variable definitions per OS/environment
└── secrets/              # Encrypted secrets
```

### Key Variables

| Variable        | Default                              | Description                                                           |
| --------------- | ------------------------------------ | --------------------------------------------------------------------- |
| `user_name`     | `$env:USERNAME`                      | Default username for templates                                        |
| `default_shell` | `powershell` / `zsh`                 | Sets primary shell for new terminals                                  |
| `editor`        | `nvim`                               | Default editor for CLI and templates                                  |
| `dotfiles_dir`  | `~/.dotfiles`                        | Path to chezmoi-managed dotfiles                                      |
| `fonts_dir`     | `~/.local/share/fonts` (Linux/macOS) | Target directory for font installation                                |
| `proxy`         | `null`                               | HTTP/HTTPS proxy for package managers and CLI tools                   |
| `platform`      | Auto-detected                        | OS platform identifier (`windows`, `darwin`, `ubuntu`, `arch`, `wsl`) |

> All variables can be overridden in `data/<platform>.yaml` or via environment variables.

---

## 🔹 Ansible Configuration

### Directory Structure

```text
ansible/
├── inventories/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── playbooks/
│   └── <platform>/
│       ├── main.yml
│       ├── tasks/
│       └── requirements.yml
└── group_vars/
    ├── all.yml
    └── <platform>.yml
```

### Key Playbook Variables

| Variable                      | Default                 | Description                                          |
| ----------------------------- | ----------------------- | ---------------------------------------------------- |
| `ansible_user`                | `$env:USERNAME`         | Remote user for SSH/WinRM connections                |
| `ansible_become`              | `true`                  | Elevate privileges when provisioning                 |
| `ansible_python_interpreter`  | `/usr/bin/python3`      | Python path for Linux hosts                          |
| `dotfiles_install_path`       | `~/.dotfiles`           | Location for chezmoi to apply templates              |
| `fonts_install`               | `true`                  | Enable font installation                             |
| `tools_install`               | `true`                  | Install essential developer tools                    |
| `enable_winrm_https`          | `true` (Windows only)   | Configure HTTPS WinRM listener for remote management |
| `winrm_export_path`           | `C:\WinRM-Certificates` | Certificate export path for Windows hosts            |
| `dotfiles_templates_override` | `null`                  | Path to custom template overrides                    |

---

## 🔹 Platform-specific Overrides

| Platform | Variable Examples                                |
| -------- | ------------------------------------------------ |
| Windows  | `powershell_profile_path`, `chocolatey_packages` |
| macOS    | `brew_packages`, `mas_apps`                      |
| Ubuntu   | `apt_packages`, `snap_packages`                  |
| Arch     | `pacman_packages`, `aur_helper`                  |
| WSL      | Hybrid: mix of Linux and Windows variables       |

> Overrides are defined per platform in `data/<platform>.yaml` or `group_vars/<platform>.yml`.

---

## 🔹 Environment Variables

| Variable                      | Purpose                                            |
| ----------------------------- | -------------------------------------------------- |
| `DOTFILES_ENV`                | Sets active environment (`dev`, `staging`, `prod`) |
| `CHEZMOI_SOURCE`              | Path to chezmoi repo (useful for testing)          |
| `ANSIBLE_CONFIG`              | Path to Ansible config file                        |
| `ANSIBLE_VAULT_PASSWORD_FILE` | File containing vault password for secrets         |

> Environment variables take precedence over default template values.

---

## 🔹 Secrets Management

* **chezmoi secrets** – `chezmoi secret edit <file>`
* **Ansible Vault** – `ansible-vault edit <file>`
* Secrets are referenced in templates and playbooks using variable placeholders.
* Never commit plaintext secrets to Git.

---

## 🔹 Example Workflow

1. Clone dotfiles repo:

```bash
git clone https://github.com/yourorg/dotfiles.git ~/.dotfiles
```

2. Initialize chezmoi:

```bash
chezmoi init ~/.dotfiles
```

3. Override variables:

```bash
export DOTFILES_ENV=dev
chezmoi apply
```

4. Run Ansible provisioning:

```bash
ansible-playbook playbooks/$(uname | tr '[:upper:]' '[:lower:]')/main.yml
```

5. Post-install validation ensures tools, fonts, and services are correctly installed.

---

## 🔹 Philosophy

> Machines are disposable. Configuration is not.

All configuration is **modular, environment-aware, and reproducible**, allowing new machines to be bootstrapped **from zero to fully provisioned** in minutes.
