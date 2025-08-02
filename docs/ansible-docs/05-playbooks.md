---
id: 05-playbooks
title: 📘 Ansible Playbooks
description: Write and run Ansible playbooks to automate configuration, deployment, and orchestration.
sidebar_position: 5
---

# 📘 Ansible Playbooks

Playbooks are the heart of Ansible automation. They define **what tasks to run** on **which hosts**, and in **what order**.

---

## 🧾 What’s a Playbook?

An **Ansible playbook** is a YAML file describing automation logic in human-readable form. Each playbook consists of one or more *plays*, and each play maps hosts to tasks.

---

## ✍️ Minimal Example

Here’s a minimal playbook that installs `nginx`:

```yaml
# playbooks/nginx.yml
- name: Install NGINX on web servers
  hosts: web
  become: true
  tasks:
    - name: Install nginx
      ansible.builtin.package:
        name: nginx
        state: present
````

Run it with:

```bash
ansible-playbook -i inventory/ playbooks/nginx.yml
```

---

## 🔁 Playbook Structure

A playbook is composed of:

* **Hosts**: Target group or host.
* **Tasks**: List of actions (e.g., install a package).
* **Handlers** *(optional)*: Triggered by `notify`.
* **Variables**: Custom values you can reuse.
* **Roles** *(recommended)*: Modular, reusable task sets.

---

## 🧠 Tasks and Modules

Tasks define **what to do**. Use built-in or custom modules:

```yaml
tasks:
  - name: Copy config file
    ansible.builtin.copy:
      src: files/nginx.conf
      dest: /etc/nginx/nginx.conf
```

---

## 🔔 Handlers

Handlers run only when notified:

```yaml
tasks:
  - name: Update nginx config
    ansible.builtin.template:
      src: nginx.conf.j2
      dest: /etc/nginx/nginx.conf
    notify: Restart nginx

handlers:
  - name: Restart nginx
    ansible.builtin.service:
      name: nginx
      state: restarted
```

---

## ⚙️ Variables

Define and use variables:

```yaml
vars:
  my_package: nginx

tasks:
  - name: Install package
    ansible.builtin.package:
      name: "{{ my_package }}"
      state: present
```

You can also define variables in:

* `host_vars/`
* `group_vars/`
* `vars_files:`
* `--extra-vars` on the command line

---

## 📂 Directory Layout

```bash
ansible/
├── inventory/
│   └── inventory.ini
├── playbooks/
│   ├── nginx.yml
│   └── site.yml
└── roles/
```

Use `site.yml` to call other playbooks or roles:

```yaml
- import_playbook: nginx.yml
- import_playbook: users.yml
```

---

## 🛠️ Real-World Tips

* Always use `become: true` when making system changes.
* Add `tags:` to tasks so you can run selected parts.
* Use `--check` for dry runs, and `--diff` to view file changes.
* Keep logic minimal—offload complexity to roles or Jinja2 templates.

---

## 🚀 Run a Full Playbook

```bash
ansible-playbook -i inventory/ playbooks/site.yml
```

Add `--limit`, `--tags`, or `--check` to customize execution.

---

## 📌 Next Steps

You’ve just written your first playbook. From here, learn how to structure complex projects using [roles](./04-roles.md).
