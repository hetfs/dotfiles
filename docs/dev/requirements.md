---
id: requirements
title: 📦 Galaxy Role Requirements
description: Modular and platform-specific Ansible role requirements using requirements.yml files
sidebar_position: 6
---

# 📦 Ansible Galaxy Role Requirements

This project uses modular, platform-specific [`requirements.yml`](https://docs.ansible.com/ansible/latest/galaxy/user_guide.html#installing-roles-from-files) files to install and manage Ansible Galaxy roles.

Each platform has its own `requirements.yml` to declare relevant role dependencies, while shared roles live in `common/`.

This makes the provisioning system **clean**, **maintainable**, and **extensible** across Linux, Windows, macOS, WSL, and more.

---

## 🧭 File Layout

```bash
dotfiles/
├── common/
│   └── requirements.yml        # ✅ Shared roles for all platforms
├── ubuntu/
│   └── requirements.yml        # 🐧 Ubuntu-only roles
├── arch/
│   └── requirements.yml        # 🅰️ Arch-only roles
├── darwin/
│   └── requirements.yml        # 🍏 macOS-only roles
├── windows/
│   └── requirements.yml        # 🪟 Windows-only roles
├── wsl/
│   └── requirements.yml        # 💠 WSL-only roles
````

---

## 🧩 Shared Roles (`common/requirements.yml`)

These roles are installed on all platforms:

```yaml title="common/requirements.yml"
- name: geerlingguy.dotfiles
- name: gantsign.oh-my-zsh
- name: gantsign.antigen
- name: dev-sec.ssh-hardening
- name: dev-sec.os-hardening
```

---

## 🐧 Ubuntu

```yaml title="ubuntu/requirements.yml"
- name: geerlingguy.apt
- name: geerlingguy.docker
- name: geerlingguy.git
- name: weareinteractive.ufw
```

---

## 🅰️ Arch Linux

```yaml title="arch/requirements.yml"
- name: tschifftner.pacman
  src: https://github.com/tschifftner/ansible-role-pacman

- name: custom.yay
  src: https://github.com/binahf/ansible-role-yay
  version: main

- name: geerlingguy.git
```

---

## 🍏 macOS (Darwin)

```yaml title="darwin/requirements.yml"
- name: geerlingguy.homebrew
- name: geerlingguy.mac
- name: custom.dotfiles
  src: https://github.com/binahf/ansible-role-dotfiles
```

---

## 🪟 Windows

```yaml title="windows/requirements.yml"
- name: community.windows
- name: chocolatey.chocolatey
- name: custom.win_config
  src: https://github.com/binahf/ansible-role-windows-config
```

---

## 💠 WSL

```yaml title="wsl/requirements.yml"
- name: gantsign.oh-my-zsh
- name: gantsign.antigen
- name: geerlingguy.git
- name: dev-sec.ssh-hardening
```

---

## 🚀 Usage Pattern

Each playbook (e.g., `ubuntu/main.yml`, `windows/main.yml`) loads both shared and platform-specific roles:

```yaml title="ubuntu/main.yml"
- name: Install roles
  hosts: localhost
  connection: local
  gather_facts: false
  tasks:
    - name: Install common roles
      ansible.builtin.command:
        cmd: ansible-galaxy install -r ../common/requirements.yml

    - name: Install Ubuntu-specific roles
      ansible.builtin.command:
        cmd: ansible-galaxy install -r requirements.yml
```

You can also automate this via `scripts/run.sh`.

---

## ✅ Benefits

| Feature           | Description                                          |
| ----------------- | ---------------------------------------------------- |
| 📦 Modular        | Each OS defines its own dependencies                 |
| ✅ DRY             | Shared roles live in `common/`, no repetition needed |
| 🧩 Flexible       | Easy to extend for new OSes or edge-case setups      |
| 🔁 CI/CD Friendly | Platform-specific role install steps for pipelines   |
| 📚 Documentable   | Each `requirements.yml` is self-contained and clean  |

---

## 🔧 Optional Script

`scripts/install-roles.sh` to install the correct roles per detected platform
