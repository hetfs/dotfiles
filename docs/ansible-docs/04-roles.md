---
id: 10-roles
title: 🧩 Ansible Roles
description: Modularize your playbooks using roles for reusable automation.
sidebar_position: 10
---

# 🧩 Ansible Roles

Ansible **roles** help you organize complex automation into reusable, self-contained units. They make your playbooks *modular*, *scalable*, and *easier to maintain or share*.

---

## 🧱 What Is a Role?

A **role** is a standardized directory structure that contains all the automation resources for a specific task or component—such as installing `nginx`, configuring `docker`, or setting up a user account.

Roles let you avoid repetition and keep playbooks clean by reusing code across different projects and environments.

---

## 📁 Role Directory Structure

A role lives in its own folder and typically includes:

```bash
roles/
└── nginx/
    ├── defaults/           # Lowest-priority variables
    │   └── main.yml
    ├── files/              # Static files (e.g. index.html)
    ├── handlers/           # Handlers triggered by notify
    │   └── main.yml
    ├── meta/               # Metadata (dependencies, authors)
    │   └── main.yml
    ├── tasks/              # Main logic (required)
    │   └── main.yml
    ├── templates/          # Jinja2 templates
    └── vars/               # Higher-priority variables
        └── main.yml
````

---

## ✍️ Using a Role in a Playbook

Using a role is as simple as:

```yaml
- hosts: web
  roles:
    - nginx
```

Ansible will automatically look for the `nginx` role in the `roles/` directory and load it in the correct order.

---

## 🔃 Role Execution Order

When you use a role, Ansible loads components in this sequence:

1. `defaults/main.yml`
2. `vars/main.yml`
3. `tasks/main.yml`
4. `handlers/main.yml` (if notified)
5. `meta/main.yml` (optional)

---

## 🔌 Role Variables

Define role-specific variables like this:

```yaml
# roles/nginx/defaults/main.yml
nginx_port: 80
```

Use it inside tasks or templates:

```jinja2
# roles/nginx/templates/nginx.conf.j2
listen {{ nginx_port }};
```

---

## 🚦 Handlers in Roles

Define **handlers** in `handlers/main.yml`, and call them from tasks using `notify`.

```yaml
# roles/nginx/tasks/main.yml
- name: Install nginx
  apt:
    name: nginx
    state: present
  notify: Restart nginx

# roles/nginx/handlers/main.yml
- name: Restart nginx
  service:
    name: nginx
    state: restarted
```

---

## 🪄 Role Templates

Roles can include Jinja2 templates that generate dynamic config files:

```jinja2
# roles/nginx/templates/nginx.conf.j2
server {
  listen {{ nginx_port }};
  server_name {{ ansible_hostname }};
}
```

These are used with the `template:` module.

---

## 🔁 Reuse Roles with `include_role`

You can include roles dynamically within tasks:

```yaml
- name: Conditionally load nginx
  include_role:
    name: nginx
  when: nginx_enabled | bool
```

This gives you more control than static role declarations.

---

## 📦 Installing Roles from Ansible Galaxy

You can use third-party roles from [Ansible Galaxy](https://galaxy.ansible.com):

```bash
ansible-galaxy install geerlingguy.nginx
```

Then include them in your playbook:

```yaml
- hosts: web
  roles:
    - geerlingguy.nginx
```

---

## 📜 Role Dependencies

Specify role dependencies in `meta/main.yml`:

```yaml
# roles/myapp/meta/main.yml
dependencies:
  - role: nginx
  - role: postgresql
```

Ansible will run these roles automatically before the current one.

---

## 📁 Project Layout with Roles

Here’s a typical project structure using roles:

```bash
ansible/
├── inventory/
│   └── inventory.ini
├── playbooks/
│   └── site.yml
└── roles/
    ├── nginx/
    └── postgresql/
```

Keep your roles in `roles/`, and reference them in your site-level playbook.

---

## 🛡️ Best Practices

* ✅ Create **one role per component** (e.g. `nginx`, `mysql`)
* ✅ Keep **defaults** in `defaults/main.yml` for flexibility
* ✅ Use **`vars/`** for hard overrides, sparingly
* ✅ Put **static files** in `files/`, and **Jinja2** configs in `templates/`
* ✅ Document each role via `meta/main.yml`
* ✅ Reuse roles across projects and automate everything

---

## 🚀 Next Steps

With roles in place, your playbooks become more powerful and maintainable.

Run a role-based setup:

```bash
ansible-playbook -i inventory.ini playbooks/site.yml
```

Up next: [📋 Playbooks](./11-playbooks.md) — combining roles, tasks, and logic into powerful automation flows.
