# 🔐 Security Policy

This document outlines security practices, supported versions, and how to responsibly report security issues related to this repository.

---

## 📦 Scope

This repository manages:

* Cross-platform dotfiles using **chezmoi**
* System provisioning with **Ansible**
* Bootstrap scripts for Windows, macOS, Linux, and WSL
* Secrets handling using **Ansible Vault** and **chezmoi secrets**
* Automation for developer tooling, fonts, terminals, and security hardening

Security is a first-class concern across all layers.

---

## 🛡 Supported Versions

Only the **main branch** is actively supported.

| Version       | Supported |
| ------------- | --------- |
| `main`        | ✅ Yes     |
| older commits | ❌ No      |

Always pull the latest changes before reporting issues.

---

## 🔑 Secrets Management Policy

This repository **never stores secrets in plaintext**.

### Approved mechanisms

* **Ansible Vault**

  * Used for provisioning credentials, tokens, and keys
  * Stored under `secrets/ansible-vault/`
* **chezmoi secrets**

  * Used for dotfile-level secrets
  * Encrypted locally and never committed in plaintext

### Forbidden practices

* ❌ Hardcoded secrets in playbooks or scripts
* ❌ Secrets committed to Git, even temporarily
* ❌ Credentials embedded in CI logs

If a secret is accidentally committed:

1. Rotate it immediately
2. Remove it from Git history
3. Report the incident following the steps below

---

## 🔒 Cryptography Standards

* TLS required for all remote services where applicable
* WinRM uses **HTTPS only**
* Certificates must be:

  * RSA 2048-bit or higher
  * Valid SAN entries
  * Automatically rotated where supported

Weak or deprecated algorithms are intentionally avoided.

---

## 🧪 CI and Automation Security

* CI pipelines must run without interactive secrets
* Secrets are injected via secure environment variables only
* All scripts are designed to be:

  * Idempotent
  * Non-destructive
  * Safe to re-run

---

## 🧭 Threat Model

This repository assumes:

* Machines may be rebuilt frequently
* Local machines may be compromised
* Configuration must be reproducible and auditable
* Secrets must remain protected even if dotfiles are public

Design choices prioritize **least privilege**, **defense in depth**, and **zero trust by default**.

---

## 🚨 Reporting a Security Vulnerability

If you discover a security issue:

### Do **not** open a public issue.

Instead:

1. Send a private report via email or GitHub Security Advisory
2. Include:

   * Description of the issue
   * Affected files or modules
   * Steps to reproduce (if safe)
   * Potential impact

You will receive an acknowledgment within **48 hours**.

---

## 🧯 Response Process

Once a report is received:

1. Issue is triaged and validated
2. A fix is developed privately
3. Patch is released to `main`
4. Advisory is published if appropriate

Responsible disclosure is appreciated.

---

## 🔍 Security Best Practices for Contributors

* Run `ansible-lint` before submitting changes
* Avoid `shell` tasks unless absolutely required
* Prefer native Ansible modules
* Never log secrets
* Validate user input in scripts
* Use explicit paths and strict modes in shell scripts

---

## 📚 References

* Ansible Security Guide
  [https://docs.ansible.com/ansible/latest/security.html](https://docs.ansible.com/ansible/latest/security.html)
* chezmoi Security Model
  [https://www.chezmoi.io/user-guide/security/](https://www.chezmoi.io/user-guide/security/)
* OWASP Secure Coding Practices
  [https://owasp.org/www-project-secure-coding-practices/](https://owasp.org/www-project-secure-coding-practices/)

---

## 📜 License

This security policy is provided under the MIT License and applies only to this repository.

