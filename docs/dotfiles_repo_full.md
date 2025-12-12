# Dotfiles Repository

This document describes the complete repository structure for your dotfiles project, including:

* Global `ansible.cfg`
* Platform‑specific `ansible.cfg` overrides (Windows, WSL, macOS, Ubuntu, Arch)
* Scripts, bootstrap flows, and platform-specific tooling

---

## 📁 Repository Tree

```
dotfiles/
├── README.md
├── LICENSE
├── Makefile
├── scripts/
│   ├── bootstrap.sh
│   ├── bootstrap.ps1
│   ├── install-chezmoi.sh
│   └── install-chezmoi.ps1
├── ansible/
│   ├── ansible.cfg
│   ├── requirements.yml
│   └── playbooks/
│       ├── macos/
│       │   ├── ansible.cfg
│       │   ├── main.yml
│       │   └── tasks/packages.yml
│       ├── ubuntu/
│       │   ├── ansible.cfg
│       │   ├── main.yml
│       │   └── tasks/packages.yml
│       ├── arch/
│       │   ├── ansible.cfg
│       │   ├── main.yml
│       │   └── tasks/packages.yml
│       ├── windows/
│       │   ├── ansible.cfg
│       │   ├── main.yml
│       │   └── tasks/winrm.yml
│       └── wsl/
│           ├── ansible.cfg
│           ├── main.yml
│           └── tasks/packages.yml
├── chezmoi/
│   ├── chezmoi.toml.tmpl
│   └── home/
│       ├── .gitconfig.tmpl
│       ├── .config/
│       │   ├── starship.toml.tmpl
│       │   ├── nvim/init.lua.tmpl
│       │   └── powershell/Microsoft.PowerShell_profile.ps1.tmpl
│       └── dot_shell/aliases.tmpl
├── platform/
│   ├── fonts-macos.sh
│   ├── fonts-linux.sh
│   └── fonts-windows.ps1
└── .github/workflows/ci.yml
```

---

## 🧩 Global `ansible.cfg`

```ini
# ===========================================================
# ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐
# │ H │ │ E │ │ T │ │ F │ │ S │
# └───┘ └───┘ └───┘ └───┘ └───┘
#
# 🌍 HETFS LTD. - Code for a Brighter Future
# https://github.com/hetfs/dotfiles
# Global ansible.cfg for dotfiles/ansible
# ===========================================================

[defaults]
inventory               = ansible/inventories
roles_path              = ansible/roles
collections_paths       = ansible/collections
library                 = ansible/plugins/modules

filter_plugins          = ansible/plugins/filter
action_plugins          = ansible/plugins/action
lookup_plugins          = ansible/plugins/lookup
vars_plugins            = ansible/plugins/vars
callback_plugins        = ansible/plugins/callback
strategy_plugins        = ansible/plugins/strategy

remote_tmp              = ~/.ansible/tmp
local_tmp               = ~/.ansible/tmp/local

forks                   = 20
pipelining              = true
timeout                 = 45
retry_files_enabled     = false
retry_files_save_path   = .retry/
any_errors_fatal        = false
max_fail_percentage     = 0
interpreter_python      = auto_silent

stdout_callback         = yaml
bin_ansible_callbacks   = true
force_color             = true
display_skipped_hosts   = false
deprecation_warnings    = false
host_key_checking       = false
show_custom_stats       = true

[inventory]
cache                   = true
cache_plugin            = jsonfile
cache_timeout           = 3600
enable_plugins          = auto, yaml, ini, script, host_list
gathering               = smart
fact_caching            = jsonfile
fact_caching_connection = .cache/ansible/facts
fact_caching_timeout    = 7200

[privilege_escalation]
become                  = true
become_method           = sudo
become_user             = root
become_ask_pass         = false
become_flags            = -HE

[ssh_connection]
ssh_args                = -o ControlMaster=auto -o ControlPersist=60s -o ConnectTimeout=10
control_path_dir        = ~/.ssh/ansible
control_path            = %(control_path_dir)s/%%h-%%p-%%r
pipelining              = true
ssh_transfer_method     = piped
control_master          = auto
control_persist         = 60s

[persistent_connection]
connect_timeout         = 30
command_timeout         = 60
connect_retry_timeout   = 15

[connection_winrm]
transport               = auto
kerberos                = false
read_timeout_sec        = 120
operation_timeout_sec   = 120
ca_trust_path           = ~/.config/ansible/certs
validate_certs          = true

[galaxy]
requirements_file       = requirements.yml
collections_paths       = ansible/collections
ignore_certs            = false

[colors]
highlight               = white
verbose                 = blue
warn                    = bright purple
error                   = red
debug                   = dark gray
skip                    = cyan
unreachable             = red
ok                      = green
changed                 = yellow

diff_add                = green
diff_remove             = red
diff_lines              = cyan
diff_context            = white
```

---

## Key Advantages

1. **Centralized `group_vars` per OS** simplifies variable management and reduces complex conditional logic.
2. **WSL tasks dynamically include Ubuntu tasks** to avoid duplication while supporting WSL environments.
3. **Separated SSH and fonts tasks** makes core services modular and reusable across platforms.
4. **Inventories organized by environment** support multi-stage deployments: development, staging, production.
5. **Plugins fully categorized** enable custom modules, filters, callbacks, and other extensions to remain maintainable.
