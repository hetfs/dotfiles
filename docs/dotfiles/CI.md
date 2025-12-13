# 🚀 Continuous Integration (CI) Guide

This document outlines the **CI/CD setup and workflow** for the cross-platform modular dotfiles repository. It ensures that **all changes are automatically validated, tested, and production-ready** before merging.

---

## 🔹 Objectives

* **Automated testing**: Verify scripts, playbooks, and dotfiles render correctly
* **Cross-platform validation**: Ensure Windows, macOS, Ubuntu, Arch, and WSL workflows succeed
* **Security enforcement**: Linting, secret handling, and compliance checks
* **Idempotency checks**: Confirm provisioning scripts can run multiple times without errors
* **Release readiness**: Validate artifacts, versioning, and changelog compliance

---

## 🔹 CI Workflow Overview

1. **Code Push / Pull Request Trigger**

   * Triggered on any branch push or PR creation
   * Runs platform-specific jobs in parallel

2. **Environment Setup**

   * Provision ephemeral VMs or containers
   * Install dependencies: PowerShell 7+, Python, Ansible, chezmoi, package managers

3. **Static Analysis & Linting**

   * PowerShell scripts: `PSScriptAnalyzer`
   * Ansible playbooks: `ansible-lint`
   * YAML/Markdown: `yamllint`, `markdownlint`
   * Shell scripts: `shellcheck`

4. **Dotfiles Render Test**

   * chezmoi dry-run on each OS
   * Verify template rendering and path resolution
   * Check permissions and symlink creation

5. **Playbook & Bootstrap Validation**

   * Run platform-specific Ansible playbooks in **check mode**
   * Execute bootstrap scripts on fresh VMs to test **full provisioning**
   * Confirm all services start correctly, ports open, firewall rules applied

6. **Secrets Validation**

   * Verify secrets are not committed in plaintext
   * Ensure Ansible Vault can decrypt test secrets
   * Validate `chezmoi secret` rendering

7. **Artifact & Export Validation**

   * Ensure exported files (fonts, certificates, scripts) exist
   * Validate hash sums for reproducibility

8. **Final Reporting**

   * Pass/fail status per OS
   * Upload logs, lint reports, and bootstrap output for inspection

---

## 🔹 Recommended CI Platforms

* **GitHub Actions**

  * Ideal for cross-platform testing
  * Supports Windows, macOS, Linux runners
  * Easy integration with secrets and artifacts
* **GitLab CI/CD**

  * Flexible runners for hybrid environments
  * Supports caching, artifact storage, and matrix builds
* **Azure DevOps / Jenkins**

  * Enterprise-grade pipelines
  * Recommended for large-scale deployments

---

## 🔹 Example GitHub Actions Workflow

```yaml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:

jobs:
  ubuntu:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install dependencies
        run: |
          sudo apt update
          sudo apt install -y python3-pip ansible
      - name: Lint Ansible
        run: ansible-lint playbooks/ubuntu/
      - name: Test Bootstrap
        run: ./scripts/bootstrap.sh --dry-run

  windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install dependencies
        run: |
          choco install -y ansible powershell
      - name: Lint PowerShell
        run: Invoke-ScriptAnalyzer -Path ./scripts/win-scripts/
      - name: Test WinRM Provisioning
        run: ./scripts/win-scripts/Enable-WinRM.ps1 -ExportPath "C:\Temp\Certs" -PfxPassword "Test123!"
```

> Repeat similar jobs for macOS, Arch Linux, and WSL environments.

---

## 🔹 Best Practices

* **Matrix builds**: Test each OS independently
* **Fail fast**: Stop on first critical error to reduce wasted compute
* **Idempotency tests**: Run bootstrap multiple times to ensure no side-effects
* **Artifact caching**: Cache package managers and dependencies for faster builds
* **Secrets handling**: Use encrypted secrets in CI, never expose them in logs

---

## 🔹 CI Secrets & Environment Variables

| Variable                 | Description                                      |
| ------------------------ | ------------------------------------------------ |
| `ANSIBLE_VAULT_PASSWORD` | Vault password for provisioning secrets          |
| `CHEZMOI_SECRET_KEY`     | Key for chezmoi secret management                |
| `CI_EXPORT_PATH`         | Temporary path for exported files (fonts, certs) |
| `TEST_CREDENTIALS`       | Optional credentials for remote service tests    |

---

## 🔹 Troubleshooting

* **Lint Failures**: Check `*.lint.log` files in artifacts
* **Bootstrap Failures**: Review logs for service start errors or permission issues
* **Secrets Errors**: Ensure environment variables are set correctly
* **Network/Firewall Issues**: Validate ports (e.g., 5986 for WinRM) are open in ephemeral test VMs

---

This CI setup ensures **full confidence** that the dotfiles repository remains **reproducible, secure, and fully automated** across all supported platforms.
