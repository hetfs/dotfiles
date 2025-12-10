# ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐

# │ H │ │ E │ │ T │ │ F │ │ S │

# └───┘ └───┘ └───┘ └───┘ └───┘

#

# 🌍 HETFS LTD. - Code for a Brighter Future

# [https://github.com/hetfs/dotfiles](https://github.com/hetfs/dotfiles)

# ansible Directory Structure

This is the root directory for all automation tasks. Everything related to provisioning, configuration, remote execution, and orchestration lives here. Keeping it separate from your dotfiles ensures that the configuration management layer stays modular and clean.

```
ansible/
├── ansible.cfg
├── inventories/
│   ├── development/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   │       └── all.yml
│   ├── staging/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   └── production/
│       ├── hosts.yml
│       └── group_vars/
├── playbooks/
│   ├── windows/
│   ├── ubuntu/
│   ├── arch/
│   ├── macos/
│   └── wsl/
├── roles/
│   └── base/
└── plugins/
    ├── action/
    ├── callback/
    ├── filter/
    ├── lookup/
    ├── strategy/
    └── vars/
```

---

## ansible/ansible.cfg

This is the global configuration file for Ansible. It applies to all environments (development, staging, production) unless a deeper folder overrides it.

Typical global settings include:

* Interpreter defaults
* Callback plugins (YAML output, community.general.nice_display, etc.)
* Retry file behavior
* Roles path
* SSH/WinRM transport defaults
* Fact caching
* Inventory search paths

This keeps your project predictable across any machine you target.

---

## ansible/inventories/

This folder holds everything related to **host definitions**, split into isolated environments.

Separating inventories by environment is a best practice because:

* It prevents accidental provisioning of production from the wrong inventory.
* It organizes hosts cleanly per workflow.
* CI can run against development or staging without touching real production systems.
* Variables stay scoped to the correct environment.

---

### development/

This is the environment you’ll use most. It’s for daily testing, local VMs, WSL instances, or cloud dev boxes.

#### hosts.yml

Defines the actual hosts for the development environment.
Groups can include:

* `windows`
* `ubuntu`
* `arch`
* `mac`
* `wsl`

Each host defines connection type, hostname/IP, and authentication details.

#### group_vars/all.yml

Variables here apply to all hosts in the development inventory. Common values include:

* Python interpreter path
* Package versions or installation state
* Feature flags for shell, fonts, editors
* Environment-wide configuration defaults

This prevents repeating the same values inside `host_vars` for each machine.

---

### staging/

The staging environment mirrors production closely but without risk.
It’s where you test full deployments before pushing final changes to production.

#### hosts.yml

Contains one or more staging machines—usually cloud servers or replica systems.

#### group_vars/

Often minimal, unless staging needs specialized behavior such as unique API endpoints or debug modes.

---

### production/

This environment contains your real, critical machines.

#### hosts.yml

Defines actual production hosts by hostname or IP. Usually minimal to avoid mistakes.

#### group_vars/

Used sparingly. Production should define only essential variables. Sensitive values should be encrypted with **Ansible Vault**.

---

## Summary

This layout provides:

* Clean separation of inventories
* Environment-based isolation
* Platform-agnostic structure
* Predictable behavior in CI
* Scalable host definitions across Windows, macOS, Linux, and WSL
* Room for future `host_vars` or additional groups

This structure is widely adopted for teams that require reliability and clarity as projects grow.

---

### References

* [Ansible Configuration Guide](https://docs.ansible.com/ansible/latest/reference_appendices/config.html)
* [WinRM Settings for Ansible](https://docs.ansible.com/ansible/latest/collections/ansible/windows/winrm.html)
* [Inventory & Fact Caching](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html)
