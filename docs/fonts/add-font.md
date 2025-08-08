---
id: add-font
title: 🖋️ Step-by-Step: Add a New Font
sidebar_position: 3
---

# 🖋️ Add a New Font to Your System

This guide walks you through adding a new font to your dotfiles setup using **Ansible** and **chezmoi**, with support for **macOS, Ubuntu, Arch Linux, WSL, and Windows**.

---

## ✅ Prerequisites

- Your project uses `chezmoi` + `ansible` and follows the modular layout:
```

ansible/playbooks/<platform>/tasks/fonts.yml
ansible/config/roles/base/tasks/dispatch-fonts.yml

````
- You’ve already bootstrapped a platform using your playbooks.
- The `nerd-fonts` role is ready to handle Nerd Fonts from GitHub (optional).

---

## 🚀 Step 1: Add Font Metadata

Add your new font to the default list in `ansible/config/roles/base/defaults/main.yml`.

```yaml
fonts:
- name: FiraCode
  type: nerd
- name: JetBrainsMono
  type: nerd
- name: NewFontName         # ← Add this
  type: nerd                # or 'ttf' if manually installed
````

> 💡 Set `type: nerd` to install from GitHub Nerd Fonts repo, or `ttf` for manual local `.ttf` installation.

---

## 💡 Step 2: Ensure Platform Support

Go to the platform-specific font task file:

| Platform   | Path                                        |
| ---------- | ------------------------------------------- |
| Ubuntu     | `ansible/playbooks/ubuntu/tasks/fonts.yml`  |
| Arch Linux | `ansible/playbooks/arch/tasks/fonts.yml`    |
| macOS      | `ansible/playbooks/darwin/tasks/fonts.yml`  |
| Windows    | `ansible/playbooks/windows/tasks/fonts.yml` |
| WSL        | `ansible/playbooks/wsl/tasks/fonts.yml`     |

Confirm that this task includes logic like:

```yaml
- name: Install fonts
  include_role:
    name: base
    tasks_from: dispatch-fonts
```

---

## 🧠 Step 3: Update Dispatch Logic

Your base role’s `dispatch-fonts.yml` handles platform-specific logic. Make sure it supports the new font type:

```yaml
- name: Install Nerd Fonts
  when: item.type == "nerd"
  ansible.builtin.include_tasks: nerd-font.yml
  loop: "{{ fonts }}"
```

Add a task for new types if needed (e.g., local `.ttf` fonts).

---

## 📁 Step 4: Add Local Fonts (optional)

If using custom `.ttf` files (instead of GitHub releases), place them in your chezmoi dotfiles:

```
~/.local/share/chezmoi/dot_fonts/<FontName>/<file>.ttf
```

Then update the playbook logic to copy them to the system fonts directory.

---

## 🧪 Step 5: Test the Font Install

Run your platform playbook with verbose output:

```bash
ansible-playbook -i inventories/development playbooks/ubuntu/main.yml -v
```

Or for macOS:

```bash
ansible-playbook -i inventories/development playbooks/darwin/main.yml
```

---

## 🔁 Step 6: Use the Font in Terminal/Editor

Update your editor and terminal settings:

### VS Code

* File → Preferences → Settings → Font Family

```json
"editor.fontFamily": "NewFontName Nerd Font"
```

### WezTerm

Edit `~/.config/wezterm/wezterm.lua`:

```lua
font = wezterm.font("NewFontName Nerd Font"),
```

### Neovim

In `init.lua` or `init.vim` (if applicable):

```lua
vim.opt.guifont = "NewFontName Nerd Font:h13"
```

---

## ✅ Done!

You’ve now added a font that installs across all supported platforms using a unified, secure, and CI-ready setup.

---

## 🛠️ Next Steps

* Add fallback font logic for robustness
* Configure font linking in WSL if Windows is the source
* Create a CI test using Molecule to validate the font installs

---

Need help debugging? Check logs with:

```bash
ansible-playbook ... -vvv
```

Or ask in the community! ✨
