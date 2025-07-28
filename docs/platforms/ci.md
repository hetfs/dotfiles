---
id: ci
title: 🤖 Continuous Integration (CI) Awareness
description: How the framework behaves differently when running in CI environments like GitHub Actions, GitLab, or others.
sidebar_position: 5
---

# 🤖 Continuous Integration (CI) Awareness

When running automation in a CI/CD pipeline, certain assumptions change:

- You don’t want interactive prompts.
- You may skip installing GUI tools.
- Secrets or SSH keys might not be present.

Our framework includes built-in checks and conditional logic to adapt to CI environments automatically.

## 🧠 CI Detection Logic

We detect CI context using the following indicators:

- Environment variables:
  - `CI=true` (common)
  - `GITHUB_ACTIONS`, `GITLAB_CI`, `BITBUCKET_BUILD_NUMBER`, etc.
- System-specific identifiers like:
  - `chezmoi.os` and `chezmoi.hostname`
  - Presence of `.ci` config files

```bash
# Example chezmoi template logic
{{ if (or (eq (env "CI") "true") (env "GITHUB_ACTIONS")) }}
# Running in CI – skip interactive steps
{{ end }}
````

## 🧭 CI Behavior Changes

| Feature             | CI Behavior                                |
| ------------------- | ------------------------------------------ |
| Package install     | Skips GUI apps (like `kitty`, `karabiner`) |
| Secrets / SSH setup | Skipped unless `CI_SSH_KEY` is injected    |
| Dotfiles install    | Runs non-interactive with `--no-pager`     |
| Logging             | Verbose + redirected to file/CI logs       |
| Bootstrap scripts   | Conditional logic using `if CI` checks     |

## 🧪 CI-Specific Templates

You can define CI-aware templates using `chezmoi`'s templating system:

```bash
{{ if eq (env "CI") "true" }}
# CI-only configuration
{{ else }}
# Local dev machine config
{{ end }}
```

## ✅ Supported CI Providers

Our logic currently supports:

* GitHub Actions
* GitLab CI/CD
* Bitbucket Pipelines
* CircleCI
* Jenkins (with `CI=true`)
* Drone, Travis CI, others (via generic `CI` env)

## 📂 CI-Aware Folder Structure

You can create folders that are conditionally included only in CI:

```text
.chezmoiscripts/
├── ci/
│   ├── bootstrap-ci.sh
│   └── post-install-ci.sh
```

These scripts are only sourced if running inside a CI context.

---

## 🛠️ Real World Example

In `.chezmoi.yaml.tmpl`, you might find:

```yaml
name: dotfiles
apply:
  verbose: {{ if eq (env "CI") "true" }}true{{ else }}false{{ end }}
```

This disables verbosity in local use but enables it in CI logs.

---

> 📝 Pro Tip: Use `chezmoi init --apply --verbose` in CI with a temporary home directory to ensure clean state testing.

---

```

Let me know if you want to proceed with the next file (like `01-overview.md` for the root `dotfiles/README` equivalent or something like `devcontainer.md` or `windows.md`).
```
