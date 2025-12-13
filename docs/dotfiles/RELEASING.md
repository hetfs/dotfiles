# 📦 RELEASING GUIDE

This document outlines **versioning, tagging, and changelog management** for the cross-platform dotfiles repository.

---

## 🔹 Versioning Strategy

We follow **Semantic Versioning (SemVer)**:

```
MAJOR.MINOR.PATCH
```

* **MAJOR** – Incompatible changes (breaking configuration, structural changes)
* **MINOR** – New features or platform support
* **PATCH** – Bug fixes, performance improvements, documentation updates

**Example:**

| Version | Description                                |
| ------- | ------------------------------------------ |
| 2.0.0   | Major restructuring for CI + modularity    |
| 2.1.0   | Added Windows 11 provisioning improvements |
| 2.1.1   | Fixed WinRM HTTPS listener idempotency     |

---

## 🔹 Tagging Releases

1. Ensure your working branch is clean and up-to-date:

```bash
git checkout main
git pull origin main
```

2. Create a new **tag**:

```bash
git tag -a v2.1.1 -m "Fix WinRM HTTPS listener idempotency"
git push origin v2.1.1
```

> Tags should always match **SemVer** and reflect production-ready code.

3. Use annotated tags (`-a`) to provide a message describing the release.

---

## 🔹 Changelog Discipline

Maintain a **`CHANGELOG.md`** in the repo root. Follow this structure:

```markdown
# Changelog

All notable changes to this project will be documented here.

## [2.1.1] - 2025-12-13
### Fixed
- WinRM HTTPS listener now automatically updates with the newest certificate
- Firewall configuration handling improved for public networks

## [2.1.0] - 2025-12-07
### Added
- Windows 11 provisioning support
- Modular Ansible playbooks for WSL

### Changed
- Updated bootstrap scripts to handle PowerShell 7+ by default

## [2.0.0] - 2025-11-30
### Added
- Cross-platform modular dotfiles architecture
- chezmoi + Ansible integration
- Full CI/CD ready provisioning
```

**Best practices:**

* Always update `CHANGELOG.md` **before tagging a release**
* Group changes under **Added / Changed / Fixed / Removed / Deprecated**
* Include dates for each release

---

## 🔹 Release Checklist

Before tagging a new release:

1. ✅ Verify all scripts and playbooks pass CI checks
2. ✅ Ensure `CHANGELOG.md` is updated
3. ✅ Run **bootstrap** on a fresh VM to confirm idempotency
4. ✅ Confirm cross-platform dotfiles render correctly
5. ✅ Tag release in Git with annotated message
6. ✅ Push tags to remote repository
