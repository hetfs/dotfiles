# Dotfiles Project Structure

A **modular, cross-platform, and best-practice-oriented** layout for managing dotfiles, Ansible playbooks, and automation tasks.

```text
dotfiles/
├── .github/
│   ├── ansible/                # GitHub Actions workflows specific to Ansible CI/CD
│   └── workflows/              # General GitHub Actions workflows
│
├── ansible/
│   ├── collections/            # Galaxy collections used or vendored
│   ├── group_vars/             # Global and per-OS variables
│   │   ├── all.yml             # Global variables (system, dev tools, fonts)
│   │   ├── ubuntu.yml
│   │   ├── arch.yml
│   │   ├── darwin.yml
│   │   ├── windows.yml
│   │   └── wsl.yml
│   ├── inventories/            # Inventory files
│   │   ├── development/
│   │   ├── staging/
│   │   └── production/
│   ├── playbooks/              # Platform-specific playbooks
│   │   ├── arch/
│   │   │   └── tasks/
│   │   │       ├── main.yml
│   │   │       └── packages.yml
│   │   ├── darwin/
│   │   │   └── tasks/
│   │   │       ├── main.yml
│   │   │       └── packages.yml
│   │   ├── ubuntu/
│   │   │   └── tasks/
│   │   │       ├── main.yml
│   │   │       ├── packages.yml
│   │   │       └── ssh.yml
│   │   ├── windows/
│   │   │   └── tasks/
│   │   │       ├── main.yml
│   │   │       └── packages.yml
│   │   └── wsl/
│   │       └── tasks/
│   │           └── main.yml   # Dynamically includes Ubuntu tasks
│   ├── plugins/                # Custom modules and plugin types
│   │   ├── modules/
│   │   ├── filter/
│   │   ├── action/
│   │   ├── lookup/
│   │   ├── vars/
│   │   ├── callback/
│   │   └── strategy/
│   └── roles/                  # Reusable Ansible roles
│       └── common/
│           ├── defaults/
│           │   └── main.yml    # Default role variables
│           ├── tasks/
│           │   ├── main.yml
│           │   ├── packages/
│           │   │   ├── ubuntu.yml
│           │   │   ├── arch.yml
│           │   │   ├── darwin.yml
│           │   │   ├── windows.yml
│           │   │   └── wsl.yml # Dynamic inclusion of Ubuntu tasks
│           │   ├── ssh.yml
│           │   └── fonts.yml
│           └── vars/
│               └── main.yml
│
├── docs/
│   ├── ansible/                # Documentation for Ansible roles/playbooks
│   └── chezmoi/                # Documentation for dotfiles management
│
├── scripts/                     # Helper and bootstrap scripts
└── secrets/
    ├── ansible-vault/           # Encrypted vault files per platform
    └── chezmoi/                 # Private dotfiles / secrets for chezmoi
```

## Key Advantages

1. **Centralized `group_vars` per OS** simplifies variable management and avoids complex conditional logic in playbooks.
2. **`tasks/packages` subfolders** organizes package installations by OS within the `common` role for clarity and maintainability.
3. **WSL tasks dynamically include Ubuntu tasks** avoids duplication while supporting WSL environments.
4. **Separated SSH and fonts tasks** makes core services modular and reusable across platforms.
5. **Inventories organized by environment** supports multi-stage deployments (development, staging, production).
6. **Plugins fully categorized** facilitates custom modules, callbacks, filters, and other extensions.
