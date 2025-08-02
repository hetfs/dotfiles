---
id: win-ansible-install
title: 🪟 Installing Ansible on Windows
description: Learn how to install Ansible on Windows using WSL (recommended) or native Python (for testing only).
sidebar_position: 9
---

# 🧰 Install Ansible on Windows

To run Ansible on Windows, the **best experience** comes from using a Linux environment via **WSL (Windows Subsystem for Linux)**. Native installation is possible but **not supported** for production use.

---

## ✅ Option 1: Install Ansible via WSL (Recommended)

The most reliable way to install Ansible on Windows is by using a **Linux distribution running inside WSL 2**.

This method provides:

- Full support for all Ansible modules  
- Access to a native Linux environment  
- Seamless integration with VS Code and automation workflows  

---

### 🪛 Step 1: Install WSL and Ubuntu

Open **PowerShell as Administrator** and run:

```powershell
wsl --install
````

This installs:

* WSL 2
* The latest Ubuntu LTS distribution

> 💡 Reboot your system if prompted.
> You can also install other distributions like Debian or Kali via the Microsoft Store.

---

### 🧰 Step 2: Install Ansible Inside Ubuntu

Launch Ubuntu from the Start Menu, then run:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
```

Verify the installation:

```bash
ansible --version
```

---

### 🧪 Step 3: Use Ansible from WSL

You can now manage **Linux**, **macOS**, and **Windows** hosts using Ansible from within your WSL shell.

> 📌 If you're targeting **Windows hosts**, make sure to configure **WinRM** first using the [`winrm_https_setup.ps1`](../scripts/winrm_https_setup.ps1) script.

---

## ⚠️ Option 2: Native Windows Install (Not Recommended)

Installing Ansible directly on Windows using `pip` is not officially supported and comes with multiple limitations. It’s only suitable for testing or experimentation.

---

### 🚫 Limitations

* Many Ansible modules require Linux-only tools
* Frequent compatibility issues
* Very limited community and upstream support
* No official production support

---

### 🧪 Steps (Testing Only)

1. **Install Python 3.10+**

   👉 Download from [python.org](https://www.python.org/downloads/windows/)

2. **Install Ansible with pip**

   ```powershell
   pip install ansible
   pip install pywinrm
   ```

3. **Add Python to PATH**

   Ensure the following paths are in your `PATH`:

   ```
   %USERPROFILE%\AppData\Local\Programs\Python\Python310\
   %USERPROFILE%\AppData\Local\Programs\Python\Python310\Scripts\
   ```

4. **Verify installation**

   ```powershell
   ansible --version
   ```

---

## 🔍 Validate Your Ansible Setup

From inside WSL, try pinging a Windows host:

```bash
ansible -i hosts windows -m win_ping
```

Make sure:

* Your `hosts` inventory file is properly defined
* WinRM is configured and accessible on the target Windows host

---

## 🔗 Resources

* 📘 [Install WSL – Microsoft Docs](https://learn.microsoft.com/en-us/windows/wsl/install)
* 📘 [Ansible Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* 📘 [Managing Windows with WinRM](https://docs.ansible.com/ansible/latest/user_guide/windows_winrm.html)

---

## ✅ TL;DR — Which Method Should You Use?

| Environment          | Install Method          | Recommended | Notes                                    |
| -------------------- | ----------------------- | ----------- | ---------------------------------------- |
| **WSL (Ubuntu)**     | `apt` via PPA           | ✅ Yes       | Best compatibility and support           |
| **Windows (native)** | Python + `pip`          | ⚠️ No       | For testing only — limited functionality |
| **WSL + VS Code**    | Devcontainer/Remote WSL | ✅ Yes       | Ideal for development experience         |

---

## 🧰 Bonus: Use VS Code + Remote WSL

For an enhanced dev workflow:

1. Install [Visual Studio Code](https://code.visualstudio.com/)
2. Install the **Remote - WSL** extension
3. Open your WSL project directly from VS Code

> This gives you full Ansible + Python development in Linux while working in Windows.
