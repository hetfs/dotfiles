---
id: security
title: 🔐 Security Practices
description: Secure your dotfiles and infrastructure using GPG, age, and best practices.
slug: /security
sidebar_position: 1
---

# 🔐 Security Practices

Security is a first-class citizen in this automation framework. From encrypted secrets to role-based separation of credentials, everything is built with **confidentiality, integrity, and reproducibility** in mind.

## 🔑 Encryption Options

You can encrypt secrets using:

- **GPG** – Traditional and powerful, with good tooling and ecosystem support.
- **age** – A modern, minimal alternative to GPG. Easier to use and script.

Both are supported by `chezmoi` and `ansible-vault`.

## 📦 Managing Secrets with Chezmoi

Use `chezmoi` to manage and encrypt secrets in `.tmpl` or `.age` files:

```bash
chezmoi secret add ~/.config/myapp/config.toml
````

Chezmoi will handle encryption with your configured backend (GPG or age).

## 🔐 Ansible Vault

For Ansible, use:

```bash
ansible-vault encrypt secrets.yml
```

Decrypt temporarily for editing:

```bash
ansible-vault edit secrets.yml
```

Or pass the vault password file with `--vault-password-file`.

## 🔁 Key Rotation

* Rotate your keys regularly (especially GPG).
* Update encrypted files with the new keys using `chezmoi re-encrypt`.

## 📁 Sensitive File Patterns

Make sure your `.chezmoiignore` and `.gitignore` includes these:

```
/secrets/*
*.key
*.pem
*.vault
```

## ✅ Best Practices Checklist

* [x] Use asymmetric encryption (GPG or age keypairs)
* [x] Never store plain-text secrets in Git
* [x] Use separate keys per machine if possible
* [x] Back up your private keys securely
* [x] Automate key rotation if managing multiple environments

---

Want to explore more? Check the official [`chezmoi` docs](https://www.chezmoi.io/user-guide/secrets/) and [Ansible Vault guide](https://docs.ansible.com/ansible/latest/user_guide/vault.html).
