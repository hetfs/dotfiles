# 🏗 ARCHITECTURE

End-to-end design for a modular, cross-platform dotfiles and provisioning system built with **chezmoi**, **Ansible**, and **CI automation**.

---

## 🎯 Goals

This architecture is designed to:

* Support **multiple operating systems** from a single repository
* Separate **user configuration** from **system provisioning**
* Enforce **idempotency** and **reproducibility**
* Enable **secure secrets management**
* Work reliably in **local setups and CI pipelines**
* Allow machines to be **fully disposable**

> Machines are ephemeral. Configuration is source-controlled.

---

## 🧱 High-Level Overview

```text
┌──────────────┐
│ Bootstrap    │
│ Script       │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ chezmoi      │  → dotfiles, templates, user config
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Ansible      │  → OS provisioning, services, security
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Validation   │  → tools, fonts, services
└──────────────┘
```

---

## 🧩 Responsibility Separation

| Layer     | Responsibility              |
| --------- | --------------------------- |
| Bootstrap | Install prerequisites only  |
| chezmoi   | User dotfiles and templates |
| Ansible   | System-level provisioning   |
| CI        | Validation and enforcement  |

Each layer is intentionally **narrow in scope**.

---

## 🚀 Bootstrap Layer

### Purpose

Minimal entry point to get a clean system ready.

### Responsibilities

* Install package manager
* Install chezmoi
* Install Ansible
* Clone dotfiles repo
* Trigger initial apply

### Non-goals

* No configuration logic
* No secrets
* No OS-specific tuning

Bootstrap scripts live under:

```text
scripts/bootstrap/
```

They are intentionally small and auditable.

---

## 🎨 chezmoi Layer

### Purpose

Manage **user-level configuration**.

### What chezmoi manages

* Shell configuration
* Editor configs
* Git settings
* Dotfile templates
* Per-OS conditional rendering

### Structure

```text
home/
├── .zshrc.tmpl
├── .gitconfig.tmpl
├── .config/
│   └── nvim/
└── private_dot_*
```

### Key properties

* Declarative
* Templated per OS
* Secrets encrypted
* Safe to re-apply

chezmoi never:

* Installs system packages
* Modifies services
* Requires root

---

## ⚙ Ansible Layer

### Purpose

Handle **system provisioning** and **security configuration**.

### What Ansible manages

* Packages and dependencies
* Services and daemons
* Fonts
* Security hardening
* WinRM, SSH, firewall rules
* OS-level configuration

### Playbook layout

```text
ansible/playbooks/
├── ubuntu/
│   ├── main.yml
│   ├── requirements.yml
│   └── tasks/
├── windows/
├── arch/
├── darwin/
└── wsl/
```

### Design rules

* No shared `common/` role
* Platform-specific tasks only
* Idempotent by default
* Variables validated early

---

## 🧠 Base Role Pattern

A minimal `base` role provides shared logic without shared tasks.

```text
ansible/roles/base/
├── defaults/
├── tasks/
└── handlers/
```

Responsibilities:

* Variable validation
* OS dispatch logic
* Shared helpers

This avoids cross-platform coupling.

---

## 🔐 Secrets Architecture

Secrets are never stored in plaintext.

### Ansible Vault

```text
secrets/ansible-vault/
├── windows.yml
├── ubuntu.yml
└── global.yml
```

Used for:

* Tokens
* Passwords
* Keys

### chezmoi secrets

Used for:

* API tokens
* Personal credentials
* Editor secrets

Secrets are decrypted **only at runtime**.

---

## 🤖 CI Architecture

### Purpose

Prevent configuration drift and insecure changes.

### CI validates

* Ansible syntax
* Idempotency
* Linting
* Task structure
* Security regressions

### Typical CI flow

```text
Checkout
↓
Install Ansible
↓
ansible-lint
↓
Syntax check
↓
Dry-run (check mode)
```

CI never:

* Requires secrets
* Modifies real machines
* Applies destructive changes

---

## 🔁 Provisioning Flow (End-to-End)

```text
1. New machine boots
2. Run bootstrap script
3. chezmoi apply
4. Ansible playbook runs
5. Services configured
6. Validation checks pass
```

The same flow works for:

* Personal machines
* CI runners
* Cloud VMs
* Rebuilds

---

## 🛡 Security Design Principles

* Least privilege
* No implicit trust
* HTTPS-only remote access
* Explicit firewall rules
* Auditable configuration
* Secrets isolated from code

Security is enforced structurally, not by convention.

---

## 🧪 Idempotency Guarantees

Every component:

* Can run multiple times safely
* Avoids destructive defaults
* Detects existing state
* Repairs drift automatically

This enables:

* Continuous provisioning
* Automated recovery
* Safe experimentation

---

## 📦 Why This Architecture Works

* Scales from one laptop to fleets
* Clear mental model
* Easy to debug
* Easy to extend
* Safe by default

---

## 📚 References

* chezmoi architecture
  [https://www.chezmoi.io/user-guide/overview/](https://www.chezmoi.io/user-guide/overview/)
* Ansible best practices
  [https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
* Infrastructure as Code principles
  [https://martinfowler.com/bliki/InfrastructureAsCode.html](https://martinfowler.com/bliki/InfrastructureAsCode.html)
