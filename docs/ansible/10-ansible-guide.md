---
id: 10-ansible-guide
title: 📁 Structuring an Ansible Project
description: Learn the best way to organize files and folders in an Ansible project for scalability and clarity.
sidebar_position: 10
---

# 📁 Structuring an Ansible Project

A well-organized Ansible project helps keep your automation scalable, reusable, and easy to debug. While Ansible doesn’t enforce a strict structure, following a consistent layout makes collaboration and maintenance easier—especially as your project grows.

---

## 🧱 Recommended Folder Layout

```text
my-ansible-project/
├── ansible.cfg          # (Optional) Project-specific Ansible config
├── inventory/           # Hosts and groups
│   └── hosts.ini
├── group_vars/          # Group-specific variables
│   └── all.yml
├── host_vars/           # Host-specific variables
│   └── web1.yml
├── playbooks/           # Your playbooks go here
│   └── site.yml
├── roles/               # Reusable roles
│   └── nginx/
│       ├── tasks/
│       ├── handlers/
│       ├── templates/
│       ├── files/
│       ├── vars/
│       └── meta/
└── templates/           # Global Jinja2 templates (optional)
```

---

## 🪜 Suggested Playbook Order

You don’t need to strictly follow a linear order, but a logical flow helps keep things clean and predictable. Here’s a common pattern:

1. **Pre-tasks** – Initial checks or environment setup
2. **Role Includes** – Main work handled by roles
3. **Tasks** – Specific steps not covered by roles
4. **Handlers** – Triggered by tasks when changes occur
5. **Post-tasks** – Finalization or cleanup steps

---

## 🧠 Tips for Structuring Files

* 🔄 **Group by function**: Roles should handle one responsibility (e.g., `webserver`, `firewall`).
* 🔐 **Separate secrets**: Use `ansible-vault` to protect sensitive vars (e.g., passwords, API keys).
* 🌍 **Use inventories wisely**: Maintain separate inventories for `dev`, `staging`, and `prod`.
* ⚙️ **Override with `ansible.cfg`**: Use a local `ansible.cfg` to control paths and defaults.

---

## 📦 When to Use Roles

Use roles when:

* You want reusable components (e.g., Nginx setup, Docker install).
* You're working with multiple systems or configurations.
* Your playbooks are growing large and harder to navigate.

---

## 🧪 Example Project Setup

```bash
# Set up a new structure using ansible-galaxy
ansible-galaxy init roles/nginx
```

This creates a standard folder layout for a role.

---

## ✨ Best Practices

* Keep playbooks minimal—offload logic into roles.
* Version-control everything (except secrets—encrypt those).
* Use meaningful names for tasks and handlers.
* Document your inventory and roles with comments.
