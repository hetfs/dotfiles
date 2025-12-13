# Contributing Guide

Thank you for your interest in contributing to this repository. Contributions of all kinds are welcome, including bug fixes, documentation improvements, new features, and platform enhancements.

This project is designed to be **modular**, **secure**, and **idempotent**. Please follow the guidelines below to ensure consistency and quality.

---

## 📌 Contribution Principles

* Prefer **small, focused changes** over large refactors
* Maintain **idempotency**. Tasks and scripts must be safe to run multiple times
* Keep changes **platform-scoped**. Avoid cross-platform side effects
* Follow **security-first** practices. Secrets must never be committed
* Write changes as if they will be executed in **CI or fresh machines**

---

## 🗂 Repository Structure

High-level layout:

```text
ansible/
  playbooks/
    <platform>/
      main.yml
      requirements.yml
      tasks/

scripts/
secrets/
docs/
```

Key rules:

* No shared `common/` role. All logic is platform-specific
* Each platform owns its dependencies and tasks
* Scripts must be self-contained and production-safe

---

## 🧑‍💻 Development Setup

### Prerequisites

* Git
* Ansible (latest stable)
* chezmoi
* Python 3.x
* Platform-specific package managers

Optional but recommended:

* Taskfile
* direnv

### Clone the Repository

```bash
git clone https://github.com/<your-org>/<repo>.git
cd <repo>
```

### Initialize chezmoi (Dry Run)

```bash
chezmoi init --apply=false
```

### Validate Ansible Syntax

```bash
ansible-playbook --syntax-check ansible/playbooks/<platform>/main.yml
```

---

## 🧩 Ansible Guidelines

* Tasks must be **idempotent**
* Use modules instead of shell commands where possible
* Avoid hard-coded paths and values
* Prefer variables with sane defaults
* Validate variables before use

Example variable validation:

```yaml
- name: Validate required variables
  assert:
    that:
      - my_variable is defined
      - my_variable | length > 0
```

---

## 🪟 Windows-Specific Rules

* PowerShell scripts must:

  * Use `Set-StrictMode -Version Latest`
  * Include proper error handling
  * Be safe to re-run
* WinRM configuration must be fully automated
* Never require manual cleanup or interactive prompts

---

## 🔐 Secrets Policy

* Never commit secrets or credentials
* Use **Ansible Vault** for provisioning secrets
* Use **chezmoi secrets** for dotfiles
* Redact secrets from logs and output

If a secret is accidentally committed, rotate it immediately and notify maintainers.

---

## 🧪 Testing

Before submitting a PR:

* Run Ansible in check mode when possible
* Test on a clean VM or container
* Verify idempotency by running twice
* Confirm no secrets appear in logs

Optional tools:

* Molecule
* Trivy

---

## 📝 Commit Guidelines

* Use clear, descriptive commit messages
* Follow conventional commits when possible

Examples:

* `feat(windows): add idempotent WinRM HTTPS setup`
* `fix(ubuntu): correct apt cache handling`
* `docs: improve provisioning flow documentation`

---

## 📥 Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Make focused changes
4. Ensure tests and validation pass
5. Open a pull request with a clear description

Your PR should include:

* What changed
* Why it changed
* Platforms affected
* Testing performed

---

## 🧭 Code of Conduct

Be respectful, constructive, and professional.
Harassment, discrimination, or abusive behavior will not be tolerated.

---

## 🙌 Getting Help

If you are unsure about a change:

* Open a draft pull request
* Start a discussion or issue
* Ask questions early

Contributions that improve reliability, security, and clarity are especially appreciated.

Thank you for helping make this project better.
