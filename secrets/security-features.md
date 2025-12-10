# 🔐 Security Features

## 1. Dual Vault System

This repo separates secrets for **dotfiles** and **provisioning**, ensuring better security and compliance:

```bash
# Chezmoi secrets (dotfiles, personal configs)
chezmoi add --encrypt ~/.ssh/id_rsa

# Ansible secrets (playbooks, credentials)
ansible-vault encrypt secrets/ansible-vault/prod.yml
```

* **Chezmoi** handles individual user secrets (like SSH keys, API tokens).
* **Ansible Vault** secures provisioning secrets (like database passwords or API credentials).

---

## 2. Task-Level Controls

Security hardening and sensitive tasks are **conditionally executed** using Ansible variables:

```yaml
- name: Apply CIS benchmarks
  include_tasks: tasks/cis.yml
  when: security_hardening_enabled
```

* `security_hardening_enabled` can be toggled per environment.
* Prevents accidental execution of sensitive tasks on dev systems.

---

## 3. Audit-Ready Layout

The repo is designed for **auditability and compliance**:

* `test/` directory includes Molecule scenarios to **validate roles and playbooks**.
* Supports automated checks to ensure configuration matches **CIS benchmarks** and internal policies.
* Enables **quarterly audits** and traceable secret rotations.

---

**Learner Notes:**

* Always separate secrets by purpose (dotfiles vs provisioning).
* Use conditional execution for tasks that modify system security.
* Include tests for every role to maintain compliance and catch misconfigurations early.
