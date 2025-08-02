---
id: 07-variables
title: ✨ Ansible Variables
description: Use variables to simplify and customize your Ansible playbooks and roles.
sidebar_position: 7
---

# ✨ Ansible Variables

Variables in Ansible let you reuse values, customize behavior, and keep playbooks clean and flexible.

Think of them as *shortcuts* to values you’ll reference multiple times.

---

## 📌 Why Use Variables?

- 💡 Avoid duplication
- ⚙️ Customize behavior per host or group
- 🔐 Manage secrets or configuration cleanly
- 🧪 Enable conditionals and templating

---

## 🔤 Basic Syntax

```yaml
vars:
  app_port: 3000

tasks:
  - name: Open firewall port
    ufw:
      rule: allow
      port: "{{ app_port }}"
````

Use `{{ variable_name }}` to insert a variable into a task or template.

---

## 🗂️ Where to Define Variables

| Location                       | Scope                    | Priority |
| ------------------------------ | ------------------------ | -------- |
| `vars:` inside a playbook      | Local to that play       | High     |
| `group_vars/<group>.yml`       | For all hosts in group   | Medium   |
| `host_vars/<host>.yml`         | For a specific host      | Higher   |
| `defaults/main.yml` (in roles) | Lowest priority defaults | Low      |
| `vars/main.yml` (in roles)     | Higher than defaults     | High     |
| Extra vars via `--extra-vars`  | Overrides everything     | Highest  |

---

## 📁 Directory Structure Example

```bash
inventory/
├── group_vars/
│   └── web.yml      # Variables for [web] group
├── host_vars/
│   └── server1.yml  # Variables for server1
```

---

## 🧠 Variable Precedence

Ansible resolves variable conflicts by **precedence**. If the same variable exists in multiple places, the one with **higher priority** wins.

Use this to safely override defaults for specific hosts or environments.

---

## 🧪 Example with Host and Group Vars

```ini
# inventory.ini
[web]
web1 ansible_host=192.168.1.10
web2 ansible_host=192.168.1.11
```

```yaml
# group_vars/web.yml
app_port: 8080
```

```yaml
# host_vars/web2.yml
app_port: 9090
```

`web1` will use port `8080`, but `web2` will use `9090`.

---

## 🔐 Using Vault with Variables

Encrypt sensitive variable files using **Ansible Vault**:

```bash
ansible-vault encrypt group_vars/production.yml
```

Then unlock during playbook run:

```bash
ansible-playbook site.yml --ask-vault-pass
```

---

## ✅ Best Practices

* Use `defaults/` for role defaults, override in playbooks or inventory.
* Stick to clear, consistent names: `app_port`, `db_user`, `env`.
* Avoid hardcoded secrets—use Ansible Vault.
* Leverage `group_vars/` and `host_vars/` for clean overrides.

---

## 🧭 What's Next?

Next up: [📄 Templates](./08-templates.md) — generate dynamic config files with Jinja2 templates.

