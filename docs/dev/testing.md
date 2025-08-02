---
id: testing
title: 🧪 Testing
description: Test your Ansible playbooks, roles, and automation workflows with Molecule and CI
sidebar_position: 6
---

# 🧪 Testing Your Ansible Roles

This guide introduces how to test your Ansible roles and playbooks using [Molecule](https://molecule.readthedocs.io/en/latest/), plus local and CI strategies to ensure reliability before provisioning.

> ✅ Use this in combination with [Linting](./linting.md) to catch both *style issues* and *functional failures*.

---

## 🚦 Why Use Molecule?

Molecule allows you to:

- Test Ansible roles in **isolated containers/VMs**
- Simulate **real playbook runs**
- Validate **idempotence**, **convergence**, and **expected output**
- Automate testing before deploying to real hosts

---

## 🔧 Setup

Make sure you have these tools installed:

```bash
pipx install molecule ansible-lint yamllint docker
````

> You can also use `podman` instead of Docker.

Then create a test scenario:

```bash
cd common/roles/myrole
molecule init scenario -r myrole -d docker
```

This creates a `molecule/` folder with a default test scenario.

---

## 🧪 Local Testing

To test a role:

```bash
cd common/roles/myrole
molecule test
```

This runs:

* `molecule create` – set up containers
* `molecule converge` – run your role
* `molecule verify` – test results (optional)
* `molecule destroy` – clean up

For faster iteration:

```bash
molecule converge    # apply role
molecule login       # debug inside container
molecule verify      # run tests
molecule destroy     # clean up
```

---

## 📂 Suggested Structure

```
common/
└── roles/
    └── myrole/
        ├── tasks/
        ├── handlers/
        ├── molecule/
        │   └── default/
        │       ├── converge.yml
        │       ├── verify.yml
        │       └── molecule.yml
```

---

## 🤖 CI Integration (GitHub Actions)

Add `.github/workflows/test.yml`:

```yaml title=".github/workflows/test.yml"
name: Ansible Role Test

on:
  push:
    paths:
      - 'common/roles/**'
      - '.github/workflows/test.yml'

jobs:
  molecule:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Install dependencies
        run: |
          pipx install ansible
          pipx install molecule
          pipx inject molecule molecule-docker

      - name: Run molecule test
        working-directory: common/roles/myrole
        run: molecule test
```

---

## 🧪 Test Strategies

* ✅ **Minimal config test** – apply the role with defaults
* 🧪 **Edge case test** – test optional vars, OS-specific behavior
* 🔁 **Idempotency** – re-run to verify no state change
* 🐛 **Negative tests** – fail when expected vars are missing

---

## 📚 Further Reading

* [Molecule Docs](https://molecule.readthedocs.io/)
* [Molecule Scenarios](https://molecule.readthedocs.io/en/latest/scenarios.html)
* [Testinfra (Python Verifier)](https://testinfra.readthedocs.io/)

---

## ✅ Summary

* Use Molecule to simulate Ansible roles locally or in CI
* Add tests under `molecule/` in each role
* Combine with [linting](./linting.md) for full validation
* Optional: run tests automatically on GitHub Actions or other CI tools

Need help with `verify.yml` or writing Testinfra tests? Ping me!
