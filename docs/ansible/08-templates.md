---
id: 08-templates
title: 📝 Templates
description: Generate dynamic files in Ansible using Jinja2 templating.
sidebar_position: 8
---

# 📝 Templates in Ansible

Templates let you generate **dynamic configuration files** using variables. Ansible uses the **Jinja2** templating engine under the hood.

If you’ve used `{{ variable }}` in a task, you’ve already used Jinja2!

---

## 🧰 When to Use Templates

Use templates to generate:

- 🔧 Config files with host-specific values
- 📝 Service unit files (like systemd)
- 🔐 Secrets with variable injection
- 📦 Application environment files

---

## 📄 How Templates Work

1. Create a `.j2` file with placeholders.
2. Use the `template` module to copy and render it.
3. Ansible replaces placeholders with variable values.

---

## 🧪 Simple Example

```text
# templates/nginx.conf.j2
server {
  listen {{ app_port }};
  server_name {{ inventory_hostname }};
}
````

```yaml
# playbook.yml
tasks:
  - name: Generate Nginx config
    template:
      src: templates/nginx.conf.j2
      dest: /etc/nginx/sites-available/default
```

---

## 🧠 Conditional Logic in Templates

Jinja2 supports if-else, loops, filters, and more.

```jinja2
{% if enable_ssl %}
listen 443 ssl;
{% else %}
listen 80;
{% endif %}
```

```jinja2
# Loop through items
{% for user in app_users %}
- {{ user }}
{% endfor %}
```

---

## 🛠️ Filters in Templates

Jinja2 filters let you transform values.

```jinja2
{{ db_port | int }}
{{ hostname | upper }}
{{ packages | join(", ") }}
```

Common filters:

* `int`, `bool`
* `default`, `replace`
* `join`, `length`, `upper`, `lower`

Full filter list: [Jinja2 Filters Reference](https://jinja.palletsprojects.com/en/3.1.x/templates/#list-of-builtin-filters)

---

## 🔐 Secrets and Vaulted Templates

You can safely use secrets in templates:

```jinja2
DB_PASSWORD={{ vault_db_password }}
```

Make sure to encrypt secret vars using **Ansible Vault**.

---

## ✅ Best Practices

* Keep templates in a dedicated `templates/` folder.
* Use `.j2` as the file extension.
* Use `defaults/` to provide fallback values.
* Validate generated files before restarting services.
* Add comments in templates to explain logic.

---

## 📁 Directory Example

```bash
roles/
└── webserver/
    └── templates/
        └── nginx.conf.j2
```

---

## 🧭 What's Next?

Next up: [🔁 Loops and Conditionals](./09-loops.md) — repeat tasks and add logic in your playbooks.
