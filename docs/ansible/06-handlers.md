---
id: 06-handlers
title: 🔁 Ansible Handlers
description: Learn how to trigger conditional tasks using handlers for efficient configuration.
sidebar_position: 6
---

# 🔁 Ansible Handlers

**Handlers** let you run specific tasks *only when something changes*. They're ideal for restarting services, reloading configurations, or triggering follow-up actions after updates.

---

## 🧠 What Are Handlers?

A **handler** is a special task that runs *only when notified* by another task.

Think of it like this:

> “If this task results in a change, then notify a follow-up task to respond.”

---

## 🧪 When Do Handlers Run?

Handlers are queued and executed **at the end of the play**. If multiple tasks notify the same handler, it still runs **only once**, regardless of how many times it’s called.

---

## 🔧 Basic Handler Example

```yaml
# playbooks/setup.yml

- name: Install and configure Nginx
  hosts: web
  become: true
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
      notify: Restart Nginx

    - name: Deploy config
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
      notify: Restart Nginx

  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
````

In this example, if either task modifies the system, the **Restart Nginx** handler is triggered—but only once.

---

## 🪢 Notify Multiple Handlers

You can notify more than one handler from the same task:

```yaml
notify:
  - Reload systemd
  - Restart app
```

This triggers all listed handlers at the end of the play.

---

## ♻️ Handlers Are Idempotent Too

Like all Ansible tasks, handlers are **idempotent**. They only run when something has changed. No unnecessary restarts or reloads.

---

## 📁 Handlers in Roles

When using roles, define handlers in:

```
roles/<role_name>/handlers/main.yml
```

Example:

```yaml
# roles/webserver/handlers/main.yml

- name: Restart Nginx
  service:
    name: nginx
    state: restarted
```

Then notify the handler from a task inside the role:

```yaml
notify: Restart Nginx
```

---

## ✨ Best Practices

* ✅ Use handlers for tasks that must run **only after changes** (e.g., reloads, restarts).
* 🏷️ Keep handler names **clear and specific**.
* 📂 Group related handlers in the same file or block.
* 🚫 Don’t overuse handlers for tasks that don’t require conditional behavior.

---

## 🚀 Next Steps

You now know how to use handlers to make your automation more **efficient** and **responsive**.

Up next: [✨ Variables](./07-variables.md) — unlock dynamic values in your playbooks.

```

---

Let me know when you're ready for the next enhancement or if you'd like a mini sidebar TOC or callouts added!
```
