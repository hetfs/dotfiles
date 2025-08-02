---
id: what-new
title: 🆕 What’s New
description: Changelog and latest updates in the cross-platform automation framework.
sidebar_position: 2
---

# 🆕 What’s New

Stay current with the latest features, fixes, and improvements to the Cross-Platform Automation Framework. Every update aims to make automation more **reliable**, **intelligent**, and **secure**—regardless of your platform.

---

## 🗓️ July 2025

## ✅ Unified Platform Detection

- Introduced an advanced Mermaid diagram to visualize platform branching logic across Linux, macOS, Windows, WSL, and CI environments.
- Improved WSL 2 detection and added support for containerized Linux variants.
- CI mode now auto-detects non-interactive shells to enable safe, unattended provisioning.

## ✅ Winget over Chocolatey

- Switched the default Windows package manager to [**Winget**](https://learn.microsoft.com/en-us/windows/package-manager/winget/).
- Increased reliability by aligning with Microsoft-native tooling.
- Updated all provisioning scripts and templates to use Winget.

## ✅ `.devcontainer` Integration (Experimental)

- Added [**`.devcontainer.json`**](https://containers.dev/implementors/json_reference/) support for GitHub Codespaces and VS Code Remote Containers.
- Preconfigured with:
  - Neovim
  - Ansible
  - chezmoi
  - Platform-specific bootstraps
- Enables fast onboarding, reproducible dev environments, and isolated sandbox testing.

---

## ✨ Recent Enhancements

- ✅ Added Mermaid diagrams to show Linux provisioning and OS detection logic.
- ✅ Improved badge visibility: CI status, version matrix, and supported platforms.
- ✅ Refactored `README.md` with direct links to tools and provisioning workflows.
- ✅ Modularized provisioning logic by platform and distribution for easier updates.
- ✅ All documentation now passes **0 Vale errors** (Microsoft.Style, alex, write-good, spelling).

---

## 🔜 Coming Soon

- 📦 **Tool Availability Matrix** (`pkgmatrix.md`)
  Visual overview of which tools are supported across various distributions.

- 📊 **Telemetry-Free Mode**
  Offline provisioning with cryptographic signature checks and verified checksums.

- 🎯 **Role-Based Playbooks**
  Tailored automation for specific personas: DevOps, frontend, backend, data engineering, and more.

- 🧪 **Test Harness CLI**
  CLI test runner for dry-run provisioning using mocked OS, user, and platform contexts.

---

## 💬 Feedback & Contributions

We welcome your input and collaboration:

- 💡 [Open an issue](https://github.com/hetfs/dotfiles/issues) to suggest features or report bugs.
- 🔧 Submit pull requests for docs, templates, scripts, or refactoring.
- 📍 Join our GitHub Projects board to help shape the roadmap.

> Let’s build automation that works **everywhere**—together. 💻🛠️🌍
