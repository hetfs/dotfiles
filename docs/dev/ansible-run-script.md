---
id: ansible-run-script
title: 🏃‍♂️ OS-Aware Ansible Runner
description: Run the correct Ansible config based on your current OS or environment.
sidebar_position: 3
---

# 🏃‍♂️ Platform-Aware Ansible Runner

This project includes a **portable `run.sh` script** that automatically detects the current platform and runs the appropriate Ansible configuration and playbook.

---

## 🎯 What It Does

- ✅ Detects the host platform: `Linux`, `Darwin`, `WSL`, or `Windows`
- ✅ Automatically switches to the correct subdirectory (e.g., `ubuntu/`, `windows/`)
- ✅ Runs `ansible-playbook` using the correct `ansible.cfg` and `main.yml`

---

## 📄 `scripts/run.sh`

```bash title="scripts/run.sh"
#!/usr/bin/env bash

set -euo pipefail

# Detect platform
detect_platform() {
  unameOut="$(uname -s)"
  case "${unameOut}" in
    Linux*)
      if grep -qi microsoft /proc/version; then
        echo "wsl"
      elif [ -f /etc/arch-release ]; then
        echo "arch"
      elif [ -f /etc/lsb-release ] && grep -qi ubuntu /etc/lsb-release; then
        echo "ubuntu"
      else
        echo "linux"
      fi
      ;;
    Darwin*)  echo "darwin" ;;
    CYGWIN* | MINGW* | MSYS*) echo "windows" ;;
    *)        echo "unknown" ;;
  esac
}

PLATFORM="$(detect_platform)"

if [ "$PLATFORM" = "unknown" ]; then
  echo "❌ Unsupported platform: $(uname -s)"
  exit 1
fi

echo "👉 Detected platform: $PLATFORM"

CONFIG_DIR="./$PLATFORM"
PLAYBOOK="${1:-main.yml}"

if [ ! -f "$CONFIG_DIR/ansible.cfg" ]; then
  echo "❌ Missing config: $CONFIG_DIR/ansible.cfg"
  exit 1
fi

if [ ! -f "$CONFIG_DIR/$PLAYBOOK" ]; then
  echo "❌ Missing playbook: $CONFIG_DIR/$PLAYBOOK"
  exit 1
fi

echo "🚀 Running playbook: $PLAYBOOK with config: $CONFIG_DIR/ansible.cfg"

ANSIBLE_CONFIG="$CONFIG_DIR/ansible.cfg" \
cd "$CONFIG_DIR" && \
ansible-playbook "$PLAYBOOK"
````

---

## 🛠 Setup

### ✅ Make It Executable

```bash
chmod +x scripts/run.sh
```

---

### 🏁 Example Usage

```bash
./scripts/run.sh           # Runs main.yml with detected config
./scripts/run.sh setup.yml # Runs a custom playbook instead
```

---

## 🗂 Scripts Directory Layout

```txt
dotfiles/
├── scripts/
│   ├── run.sh              # 🟢 Platform-aware Ansible bootstrap
│   ├── lint.sh             # 🔍 YAML + Ansible linting
│   ├── test.sh             # 🧪 Molecule or integration testing
│   ├── secrets.sh          # 🔐 Vault utilities
│   ├── install.sh          # 🧰 System bootstrap helper
│   └── detect-platform.sh  # 🧠 Optional extracted detection logic
...
```

---

## ✅ Why Use a `scripts/` Directory?

* **Isolation** — scripts are decoupled from Ansible roles/configs
* **Tooling-friendly** — easy integration into CI, GitHub Actions, Makefiles
* **Package-friendly** — clean separation for `.deb`, `.rpm`, or `.pkg` packaging
* **ChezMoi-ready** — track via `chezmoi add scripts/run.sh`

---

## 📌 ChezMoi Integration

If you're managing your dotfiles with [`chezmoi`](https://www.chezmoi.io), be sure to:

1. Track the script:

```bash
chezmoi add scripts/run.sh
```

2. Ignore machine-local artifacts:

```bash
echo "scripts/.DS_Store" >> .chezmoiignore
```
