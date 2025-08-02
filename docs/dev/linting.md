---
id: linting
title: 🧽 Linting
description: Ensure code quality and best practices across Ansible and YAML
sidebar_position: 4
---

# 🧽 Linting Your Ansible Project

This guide shows how to lint your Ansible playbooks, roles, and YAML configs using `ansible-lint` and `yamllint`.

All linting logic is handled via a portable helper script: [`scripts/lint.sh`](../scripts/lint.sh).

---

## 🎯 Goals

- ✅ Validate syntax and structure of all YAML files
- ✅ Enforce best practices across Ansible playbooks and roles
- ✅ Apply consistently across platforms (`ubuntu/`, `windows/`, etc.)

---

## 🧪 Usage

Run the linter from your project root:

```bash
./scripts/lint.sh
````

This will:

* Lint everything inside:

  * `ansible/`
  * `common/`
  * All platform-specific directories (`ubuntu/`, `arch/`, `windows/`, etc.)

---

## 🛠 Tools Used

| Tool                                                   | Description                        |
| ------------------------------------------------------ | ---------------------------------- |
| [`ansible-lint`](https://ansible-lint.readthedocs.io/) | Ansible best practices checker     |
| [`yamllint`](https://yamllint.readthedocs.io/)         | YAML syntax and formatting checker |

---

## ⚙️ `scripts/lint.sh`

```bash title="scripts/lint.sh"
#!/usr/bin/env bash

set -euo pipefail

echo "🔍 Starting Ansible + YAML linting..."

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ANSIBLE_DIR="$ROOT_DIR/ansible"
COMMON_DIR="$ROOT_DIR/common"

PLATFORM_DIRS=(
  "$ROOT_DIR/ubuntu"
  "$ROOT_DIR/arch"
  "$ROOT_DIR/darwin"
  "$ROOT_DIR/windows"
  "$ROOT_DIR/wsl"
)

for cmd in ansible-lint yamllint; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "❌ Missing required command: $cmd"
    echo "💡 You can install it via: pipx install $cmd"
    exit 1
  fi
done

echo "✅ Tools present: ansible-lint, yamllint"

echo "🔧 Running ansible-lint..."
ansible-lint "$ANSIBLE_DIR" "$COMMON_DIR" "${PLATFORM_DIRS[@]}"

echo "🔧 Running yamllint..."
yamllint -c "$ANSIBLE_DIR/.yamllint" "$ANSIBLE_DIR" "$COMMON_DIR" "${PLATFORM_DIRS[@]}"

echo "✅ Linting completed successfully."
```

---

## 🧰 Makefile Integration (Optional)

If you're using a `Makefile`, you can add a target like:

```makefile
lint:
	./scripts/lint.sh
```

Then run:

```bash
make lint
```

---

## 📁 Chezmoi Tip

If you're tracking your scripts with Chezmoi:

```bash
chezmoi add scripts/lint.sh
```

And ignore any local-only files in `.chezmoiignore`.

---

## 📌 Summary

Linting is essential to avoid mistakes, enforce standards, and keep your automation codebase maintainable.
