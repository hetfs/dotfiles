---
id: getting-started
title: 🚀 Getting Started
sidebar_position: 3
description: Bootstrap your system using chezmoi and Ansible. Declarative, secure, and cross-platform.
---

# 🚀 Getting Started

Welcome! This guide walks you through setting up a fully automated development environment using [**chezmoi**](https://www.chezmoi.io) and [**Ansible**](https://www.ansible.com). Everything is declarative, secure, and version-controlled across platforms.

---

## 🔁 Optional: One-Liner Bootstrap

Prefer GitOps-style setup with a single command? Use a script like this:

```bash
#!/bin/bash
chezmoi init --apply https://github.com/hetfs/dotfiles
ansible-playbook ~/.config/refresh.yml
```
---

## 🧠 Tips & Best Practices

* Use `chezmoi diff` before applying to preview changes.
* Leverage template conditionals to adapt per user, OS, or architecture.
* Use Ansible roles to modularize tasks and simplify maintenance.
* Keep secrets encrypted and commit-safe using `sops`, `age`, or `1Password`.

---

## 📚 Documentation & Tools

* 📘 [chezmoi Docs](https://www.chezmoi.io/docs/)
* ⚙️ [Ansible Docs](https://docs.ansible.com/)
* 🔐 [1Password CLI Docs](https://developer.1password.com/docs/cli/)
* 🔒 [sops GitHub](https://github.com/mozilla/sops)
* 🔑 [age GitHub](https://github.com/FiloSottile/age)

---

> **Fast to set up. Easy to maintain. Designed for real-world developer workflows.**
