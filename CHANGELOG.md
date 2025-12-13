# 📝 Changelog

All notable changes to this repository will be documented in this file.
This project adheres to [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

* Placeholder for upcoming changes and enhancements.
* Update Ansible tasks and platform-specific dotfiles as needed.
* Add new tools or fonts to provisioning scripts.

---

## [2.0.0] - 2025-12-13

**Major Release — Production-ready Modular Dotfiles**

### Added

* Cross-platform support: Windows, macOS, Ubuntu/Debian, Arch Linux, WSL.
* Full modular architecture: `chezmoi` + per-platform `Ansible` playbooks.
* Secure secrets management: `chezmoi` secrets + `ansible-vault`.
* Automated bootstrap scripts for zero-to-ready machine setup.
* CI pipelines for validation and linting.
* Fonts and terminal tooling automation.
* Platform-specific tasks for developer tools and system configuration.
* WinRM HTTPS automated setup for Windows.

### Changed

* Refactored repository structure for clarity and maintainability.
* Reorganized Ansible tasks per platform.
* Improved templating in `chezmoi` for environment-based overrides.
* Enhanced idempotency for all provisioning tasks.

### Fixed

* Removed monolithic scripts in favor of modular tasks.
* Corrected PowerShell scripts for certificate management and WinRM HTTPS listener.
* Fixed cross-platform compatibility issues with path handling and environment variables.
