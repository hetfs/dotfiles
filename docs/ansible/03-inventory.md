---
id: 03-inventory
title: 🗂️ Ansible Inventory Management
description: Define, organize, and manage your Ansible target systems using inventory files.
sidebar_position: 3
---

# 🗂️ Ansible Inventory Management

Your **inventory file** tells Ansible *where* to run tasks. Think of it as a phonebook for your servers.

---

## 🧾 What Is an Inventory?

An Ansible **inventory** lists the hosts and groups that Ansible will manage. It can be as simple as an `.ini` file, a YAML structure, or even a dynamic script that pulls data from the cloud.

---

## 📄 Inventory File Formats

### INI Format (Default)

```ini
[web]
web01 ansible_host=192.168.1.100

[db]
db01 ansible_host=192.168.1.101 ansible_user=admin

[all:vars]
ansible_python_interpreter=/usr/bin/python3
````

### YAML Format (via Inventory Plugin)

```yaml
all:
  hosts:
    web01:
      ansible_host: 192.168.1.100
    db01:
      ansible_host: 192.168.1.101
      ansible_user: admin
  vars:
    ansible_python_interpreter: /usr/bin/python3
```

YAML inventories require enabling the appropriate inventory plugin (e.g., `yaml`, `constructed`, or `host_list`).

---

## 🧪 Test Your Inventory

Use the `ping` module to confirm Ansible can reach your hosts:

```bash
ansible all -i inventory.ini -m ping
```

Expected output:

```json
web01 | SUCCESS => { "ping": "pong" }
db01  | SUCCESS => { "ping": "pong" }
```

---

## 📚 Grouping Hosts

Group hosts to target them with specific tasks or playbooks:

```ini
[frontend]
web01

[backend]
db01
```

Then run a playbook against the `frontend` group only:

```bash
ansible-playbook -i inventory.ini playbooks/deploy.yml --limit frontend
```

---

## 🛠️ Host-Specific Variables

Define host-level settings inline:

```ini
[web]
web01 ansible_host=192.168.1.100 ansible_user=ubuntu ansible_port=2222
```

Or keep them in a structured directory (see below).

---

## 📦 Inventory Directory Structure

Organize variables per host or group using directories:

```bash
inventory/
├── group_vars/
│   └── all.yml
├── host_vars/
│   └── web01.yml
└── inventory.ini
```

Ansible auto-loads variables from `group_vars/` and `host_vars/`.

---

## 🔁 Dynamic Inventories

Use dynamic inventory plugins to pull hosts from cloud APIs:

```bash
ansible-inventory -i aws_ec2.yml --graph
```

Ansible supports plugins for:

* AWS EC2
* Azure
* GCP
* Docker
* Kubernetes
* Custom Python scripts

Learn more: [Dynamic Inventory Docs](https://docs.ansible.com/ansible/latest/plugins/inventory.html)

---

## ✨ Best Practices

* Use YAML for readability and structure
* Group hosts logically (`web`, `db`, `monitoring`)
* Version your `inventory/` folder with Git
* Centralize shared settings in `group_vars/all.yml`
* Use **Ansible Vault** for encrypted secrets

---

## 📥 Sample Repository Layout

```bash
ansible/
├── inventory/
│   ├── inventory.ini
│   ├── group_vars/
│   └── host_vars/
└── playbooks/
```

This structure keeps inventory and playbooks organized and portable.

---

## 🚀 Next Steps

Once your inventory is in place, you can run your first full playbook:

```bash
ansible-playbook -i inventory/ playbooks/setup.yml
