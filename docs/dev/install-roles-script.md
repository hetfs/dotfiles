---
id: install-roles-script
title: 📦 Install Ansible Roles per OS
sidebar_position: 7
description: Use the platform-aware script to install Ansible Galaxy roles and collections for your dotfiles project.
---

# 📦 install-roles.sh — Platform-Aware Role Installer

This script ensures each platform gets the **right set of Ansible roles** from `requirements.yml` — with optional support for installing Galaxy **collections** as well.

It supports platform auto-detection (`ubuntu`, `windows`, `arch`, `darwin`, `wsl`, etc.), verbose logging, and fallback logic for shared roles in `common/`.

---

## 🚀 Usage

Run the script directly from the `scripts/` directory:

```bash
./scripts/install-roles.sh
````

### ✅ Example Flags

```bash
./scripts/install-roles.sh --verbose             # Show detailed logs
./scripts/install-roles.sh --force               # Reinstall roles even if installed
./scripts/install-roles.sh --collections         # Install both roles and Galaxy collections
./scripts/install-roles.sh --log ansible.log     # Log output to file
```

---

## 📁 Files It Looks For

The script checks for both **shared** and **platform-specific** role and collection files:

| Type           | Path                          | Description                                |
| -------------- | ----------------------------- | ------------------------------------------ |
| Shared Roles   | `common/requirements.yml`     | Roles used across all systems              |
| Shared Colls.  | `common/collections.yml`      | Shared Galaxy collections (optional)       |
| Platform Roles | `<platform>/requirements.yml` | e.g. `ubuntu/requirements.yml`             |
| Platform Colls | `<platform>/collections.yml`  | Optional — for OS-specific Galaxy packages |

---

## 🧠 Detected Platforms

The script uses `uname` and additional checks to identify your platform:

| Detected Output | Meaning                     |
| --------------- | --------------------------- |
| `ubuntu`        | Debian/Ubuntu Linux         |
| `arch`          | Arch Linux                  |
| `darwin`        | macOS                       |
| `windows`       | Windows via Git Bash/MSYS   |
| `wsl`           | Windows Subsystem for Linux |

If detection fails, it exits with an error.

---

## 🛠️ Script Highlights

* ✅ Installs platform-specific **and** shared roles
* 🧰 Optional support for **Galaxy collections**
* 🔁 Can re-run with `--force` for clean installs
* 📜 Logs all output with `--log filename`
* 📦 Ready for CI/CD pipelines and local bootstrap

---

## 🗂️ Sample Project Structure

```bash
dotfiles/
├── common/
│   ├── requirements.yml         # shared roles
│   └── collections.yml          # shared collections (optional)
├── ubuntu/
│   ├── requirements.yml         # Ubuntu-specific roles
│   └── collections.yml          # optional
├── arch/
│   └── requirements.yml         # Arch Linux roles
├── scripts/
│   └── install-roles.sh         # 🔧 Platform-aware installer
```

---

## 💬 Tip

Use this script early in your setup process to make sure all roles and dependencies are available before running any playbooks.

```bash
./scripts/install-roles.sh --collections --verbose
```

---

## 🔗 Related Docs

* [🔧 Writing Platform Requirements](./requirements)
* [🚀 Running Playbooks](./run-script)
* [🧪 Testing Roles](./testing)
