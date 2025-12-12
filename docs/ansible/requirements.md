# requirements files

 `requirements.yml`** plus **platform-specific `requirements.yml` files** for:

* Windows
* macOS
* Ubuntu
* Arch
* WSL

All files include the required **HETFS LTD. header** at the top.

Everything is written in clean YAML, ready for linting, and safe for Ansible Galaxy.

---

# 🌍 Global `requirements.yml`

```yaml
# ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐
# │ H │ │ E │ │ T │ │ F │ │ S │
# └───┘ └───┘ └───┘ └───┘ └───┘
#
# 🌍 HETFS LTD. - Code for a Brighter Future
# https://github.com/hetfs/dotfiles
#
# Global Ansible Galaxy requirements for dotfiles/ansible
# =======================================================

---
collections:
  - name: ansible.windows
  - name: ansible.posix
  - name: community.general
  - name: community.windows
  - name: community.crypto
  - name: microsoft.ad
  - name: kubernetes.core

roles:
  # SSH hardening (used across Linux, macOS, WSL)
  - name: devsec.ssh-hardening

  # System hardening (optional but recommended for servers)
  - name: devsec.os-hardening

  # Universal package installer helpers
  - name: geerlingguy.homebrew         # macOS
  - name: oefenweb.sudo               # Linux privilege management
  - name: gantsign.visual-studio-code # VS Code installer for non-Windows
```

---

# 🍎 macOS `requirements.yml`

`ansible/playbooks/macos/requirements.yml`

```yaml
# ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐
# │ H │ │ E │ │ T │ │ F │ │ S │
# └───┘ └───┘ └───┘ └───┘ └───┘
#
# 🌍 HETFS LTD. - Code for a Brighter Future
# https://github.com/hetfs/dotfiles
#
# Platform-Specific Ansible Requirements for macOS
# =================================================

---
collections:
  - name: community.general

roles:
  - name: geerlingguy.homebrew
  - name: devsec.ssh-hardening
  - name: gantsign.visual-studio-code
```

---

# 🐧 Ubuntu `requirements.yml`

`ansible/playbooks/ubuntu/requirements.yml`

```yaml
# ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐
# │ H │ │ E │ │ T │ │ F │ │ S │
# └───┘ └───┘ └───┘ └───┘ └───┘
#
# 🌍 HETFS LTD. - Code for a Brighter Future
# https://github.com/hetfs/dotfiles
#
# Platform-Specific Ansible Requirements for Ubuntu
# ==================================================

---
collections:
  - name: ansible.posix
  - name: community.general

roles:
  - name: devsec.os-hardening
  - name: devsec.ssh-hardening
  - name: oefenweb.sudo
  - name: gantsign.visual-studio-code
```

---

# 🅰️ Arch Linux `requirements.yml`

`ansible/playbooks/arch/requirements.yml`

```yaml
# ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐
# │ H │ │ E │ │ T │ │ F │ │ S │
# └───┘ └───┘ └───┘ └───┘ └───┘
#
# 🌍 HETFS LTD. - Code for a Brighter Future
# https://github.com/hetfs/dotfiles
#
# Platform-Specific Ansible Requirements for Arch Linux
# =====================================================

---
collections:
  - name: ansible.posix
  - name: community.general

roles:
  - name: devsec.ssh-hardening
  - name: oefenweb.sudo
  - name: gantsign.visual-studio-code
```

---

# 🪟 Windows `requirements.yml`

`ansible/playbooks/windows/requirements.yml`

```yaml
# ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐
# │ H │ │ E │ │ T │ │ F │ │ S │
# └───┘ └───┘ └───┘ └───┘ └───┘
#
# 🌍 HETFS LTD. - Code for a Brighter Future
# https://github.com/hetfs/dotfiles
#
# Platform-Specific Ansible Requirements for Windows
# ==================================================

---
collections:
  - name: ansible.windows
  - name: community.windows
  - name: community.crypto

roles:
  # WinRM configuration and security
  - name: devsec.os-hardening
```

---

# 🐧💠 WSL `requirements.yml`

WSL uses *Ubuntu-style packages* + WSL-specific tasks.

`ansible/playbooks/wsl/requirements.yml`

```yaml
# ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐
# │ H │ │ E │ │ T │ │ F │ │ S │
# └───┘ └───┘ └───┘ └───┘ └───┘
#
# 🌍 HETFS LTD. - Code for a Brighter Future
# https://github.com/hetfs/dotfiles
#
# Platform-Specific Ansible Requirements for WSL
# ===============================================

---
collections:
  - name: ansible.posix
  - name: community.general

roles:
  - name: devsec.ssh-hardening
  - name: oefenweb.sudo
```

---

# ✅ Next Step

I can now generate:

### ✅ Full platform-specific `ansible.cfg` files

### ✅ Full playbooks (`main.yml`) for each OS

### ✅ Modular tasks (packages, shell, fonts, winrm, gpu, etc.)

### ✅ Inventory expansion (development/staging/production)

Just tell me what you want next.
