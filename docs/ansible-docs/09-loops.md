---
id: 09-loops
title: 🔁 Loops and Conditionals
description: Repeat tasks and add logic to your Ansible playbooks.
sidebar_position: 9
---

# 🔁 Loops and Conditionals

In real-world automation, you’ll often need to **repeat tasks** or run them based on **conditions**. Ansible makes this easy with built-in support for loops and conditionals.

---

## 🔁 Using Loops

Loops let you repeat a task for a list of items.

```yaml
- name: Install multiple packages
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - git
    - curl
    - htop
````

This task runs three times—once for each package.

---

### 🧠 Loop Variants

Ansible supports several loop styles:

#### List Loop

```yaml
loop:
  - alpha
  - beta
```

#### With Items (Legacy)

```yaml
with_items:
  - alpha
  - beta
```

#### Dictionary Loop

```yaml
loop:
  - { user: "alice", uid: 1001 }
  - { user: "bob", uid: 1002 }

- name: Create users
  user:
    name: "{{ item.user }}"
    uid: "{{ item.uid }}"
```

---

## 🔍 Loop Index

You can access the current loop index using `loop.index` or `loop.index0`.

```yaml
- name: Print index
  debug:
    msg: "Item {{ item }} is at position {{ loop.index }}"
  loop:
    - a
    - b
    - c
```

---

## 🔐 Looping with Files or Templates

You can loop through files or templates dynamically:

```yaml
- name: Copy config files
  copy:
    src: "{{ item }}"
    dest: "/etc/myapp/{{ item }}"
  loop:
    - app.conf
    - db.conf
```

---

## ⚙️ Conditionals

Conditionals let you **control whether a task runs**.

```yaml
- name: Install Nginx only on Ubuntu
  apt:
    name: nginx
    state: present
  when: ansible_facts['os_family'] == 'Debian'
```

---

## 🧠 Combining Loops and Conditions

You can combine them!

```yaml
- name: Add optional packages
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - zsh
    - tmux
  when: install_extras | bool
```

---

## 🧪 Loop Filters and Limits

Filter or conditionally loop with `selectattr`, `rejectattr`, or slicing:

```yaml
loop: "{{ users | selectattr('admin', 'equalto', true) | list }}"
```

---

## ✅ Best Practices

* Use `loop` over `with_items` (newer and clearer).
* Name tasks clearly when looping.
* Combine loops with conditionals for smarter logic.
* Use structured data (like dictionaries) for clarity.

---

## 🧭 What’s Next?

Coming up: [📦 Roles](./10-roles.md) — modularize your playbooks for reuse and clarity.

```

---

Would you like to continue with `roles.md` now, or move to another section?
```
