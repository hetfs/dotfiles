---
id: devcontainer
title: 🐳 Dev Containers (devcontainer.json)
description: How the framework behaves inside a Dev Container and how to optimize for containerized development environments.
sidebar_position: 6
---

# 🐳 Dev Containers (devcontainer.json)

**Dev Containers** let you define a consistent development environment using a `Dockerfile` or image and a `.devcontainer.json` config. Our automation framework detects if it's running inside a Dev Container and adapts accordingly.

---

## 🧠 Dev Container Detection Logic

We detect dev container environments using:

- The presence of `/dev/.container-env` or `/proc/1/cgroup`
- Environment variables like:
  - `CODESPACES`, `DEVCONTAINER`, `CONTAINER`, `VSCODE_CONTAINER`
- Hostname patterns like:
  - `codespaces-xyz`, `devcontainer-abc`

```bash
# chezmoi template snippet
{{ if or (env "CODESPACES") (env "DEVCONTAINER") }}
# Dev container-specific setup
{{ end }}
````

---

## ⚙️ Behavior Inside Dev Containers

| Feature             | Behavior                                            |
| ------------------- | --------------------------------------------------- |
| GUI Apps            | Skipped (e.g., `kitty`, `karabiner`, `hammerspoon`) |
| Fonts / UI Settings | Skipped unless running with GUI support (like X11)  |
| Package Managers    | Uses container-specific logic (e.g., `apt`, `apk`)  |
| Secrets             | Typically skipped unless injected via build args    |
| Shell Prompt        | Defaults to minimal and fast-loading prompt         |
| Bootstrap Scripts   | Slimmed down for container safety                   |

---

## 🧪 Container-Specific Templating

You can tailor configs using chezmoi template conditionals:

```bash
{{ if .chezmoi.hostname | contains "codespaces" }}
# Codespaces-specific settings
{{ end }}
```

Or check for `.container-env` presence in a shell script:

```bash
if [ -f "/dev/.container-env" ]; then
  echo "Running inside a container"
fi
```

---

## 🧰 Common Dev Container Use Cases

* **GitHub Codespaces**
* **VS Code Remote - Containers**
* **Podman / Docker development**
* **WSL2 + Docker Desktop**

---

## 📂 Recommended Structure

```text
.devcontainer/
├── devcontainer.json
├── Dockerfile
└── post-create.sh
```

Example `devcontainer.json`:

```json
{
  "name": "My Dotfiles Dev Environment",
  "build": {
    "dockerfile": "Dockerfile"
  },
  "postCreateCommand": "./.chezmoiscripts/devcontainer/post-create.sh"
}
```

Use `post-create.sh` to apply dotfiles inside the container context.

---

## ✅ Best Practices

* 🧹 Keep container configs minimal and reproducible.
* 🔐 Avoid injecting secrets at build time—use runtime mounts or CI secrets.
* 🧪 Test your container startup with `chezmoi init --apply` to confirm automation works.

---

> 💡 Tip: Want to skip the devcontainer logic locally? Use conditional flags or environment markers in your scripts.

---

```

Would you like to continue with another platform doc (e.g., `windows.md`, `darwin.md`, or `linux.md`)?
```
