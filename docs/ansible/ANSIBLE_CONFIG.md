# Environment Variables `ANSIBLE_CONFIG` & `ANSIBLE_ENV`

The `ANSIBLE_CONFIG` environment variable tells Ansible which `ansible.cfg` file to use.
The `ANSIBLE_ENV` variable can be used to indicate the current environment (e.g., `development`, `staging`, `production`).

How you set them depends on your shell.

---

## 1️⃣ Bash / Zsh

Set them for the current terminal session:

```bash
export ANSIBLE_CONFIG=/full/path/to/dotfiles/ansible.cfg
export ANSIBLE_ENV=development
```

* Replace `/full/path/to/dotfiles/ansible.cfg` with the absolute path to your project’s `ansible.cfg`.
* This lasts **only for the current session**.
* To make it permanent, add the lines to `~/.bashrc` or `~/.zshrc`:

```bash
export ANSIBLE_CONFIG=/home/user/dotfiles/ansible.cfg
export ANSIBLE_ENV=development
```

Reload your shell:

```bash
source ~/.bashrc
# or
source ~/.zshrc
```

---

## 2️⃣ Fish Shell

Set them for the current session:

```fish
set -x ANSIBLE_CONFIG /full/path/to/dotfiles/ansible.cfg
set -x ANSIBLE_ENV development
```

To make them permanent:

```fish
set -Ux ANSIBLE_CONFIG /full/path/to/dotfiles/ansible.cfg
set -Ux ANSIBLE_ENV development
```

---

## 3️⃣ PowerShell (Windows)

Set them for the current session:

```powershell
$env:ANSIBLE_CONFIG = "C:\Users\username\dotfiles\ansible.cfg"
$env:ANSIBLE_ENV = "development"
```

To make them permanent, add the lines to your PowerShell profile (`$PROFILE`).

---

### ✅ Verify

```bash
echo $ANSIBLE_CONFIG   # Unix/macOS
echo $ANSIBLE_ENV
# or in PowerShell
echo $env:ANSIBLE_CONFIG
echo $env:ANSIBLE_ENV
```

Any `ansible-playbook` command you run will automatically use the specified configuration and environment without needing `-c` or `--config`.

---

# Automatic Detection of Dotfiles Repo

You can automatically detect your dotfiles repo root and dynamically set `ANSIBLE_CONFIG` and `ANSIBLE_ENV`.
This is perfect for multi-platform setups, CI/CD, and avoiding hard-coded paths.

---

## 1️⃣ Bash / Zsh

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# Auto-set ANSIBLE_CONFIG and ANSIBLE_ENV
set_dotfiles_ansible_vars() {
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$repo_root" ] && [ -f "$repo_root/ansible.cfg" ]; then
        export ANSIBLE_CONFIG="$repo_root/ansible.cfg"
        export ANSIBLE_ENV="${ANSIBLE_ENV:-development}"
    fi
}

# Run at shell startup
set_dotfiles_ansible_vars
```

* Works only inside the git repo.
* Automatically sets environment if not already defined.

---

## 2️⃣ Fish Shell

Add to `~/.config/fish/config.fish`:

```fish
# Auto-set ANSIBLE_CONFIG and ANSIBLE_ENV
function set_dotfiles_ansible_vars
    set -l repo_root (git rev-parse --show-toplevel ^/dev/null)
    if test -n "$repo_root" -a -f "$repo_root/ansible.cfg"
        set -x ANSIBLE_CONFIG "$repo_root/ansible.cfg"
        set -x ANSIBLE_ENV (or $ANSIBLE_ENV development)
    end
end

# Run at shell startup
set_dotfiles_ansible_vars
```

---

## 3️⃣ PowerShell (Windows)

Add to your PowerShell profile (`$PROFILE`):

```powershell
# Auto-set ANSIBLE_CONFIG and ANSIBLE_ENV
function Set-DotfilesAnsibleVars {
    try {
        $repoRoot = git rev-parse --show-toplevel 2>$null
        if ($repoRoot -and (Test-Path "$repoRoot\ansible.cfg")) {
            $env:ANSIBLE_CONFIG = "$repoRoot\ansible.cfg"
            if (-not $env:ANSIBLE_ENV) { $env:ANSIBLE_ENV = "development" }
        }
    } catch {}
}

# Run at profile load
Set-DotfilesAnsibleVars
```

---

### ✅ How It Works

* Detects the **git repo root** automatically.
* Sets `ANSIBLE_CONFIG` to the `ansible.cfg` in the root.
* Sets `ANSIBLE_ENV` if not already defined (default: `development`).
* Works in any terminal session inside the repo.
* No hard-coded paths required — ideal for multi-machine or CI/CD setups.

---

### ⚡ Quick Temporary One-Liners

#### Unix / Linux / macOS

```bash
export ANSIBLE_CONFIG=$(git rev-parse --show-toplevel)/ansible.cfg
export ANSIBLE_ENV=development
```

#### PowerShell (Windows)

```powershell
$env:ANSIBLE_CONFIG = "$(git rev-parse --show-toplevel)\ansible.cfg"
$env:ANSIBLE_ENV = "development"
```

* Works **only inside the dotfiles repo**.
* Session ends when the terminal is closed.
