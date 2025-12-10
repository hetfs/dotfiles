# Ansible Configuration Settings

Ansible loads settings from multiple sources, and each source follows a clear precedence rule. The setting with the highest precedence is always applied.

## Configuration Sources

Ansible reads configuration from:

* `ansible.cfg` files
* Environment variables
* Command-line flags
* Playbook keywords and variables

When a setting appears in more than one source, Ansible applies the one with the highest priority.

## Configuration File Search Order

Ansible loads the first configuration file it finds in this order:

1. `ANSIBLE_CONFIG` (environment variable)
2. `ansible.cfg` in the current directory
3. `~/.ansible.cfg` in the user’s home directory
4. `/etc/ansible/ansible.cfg`

Only the first matching file is used.

## File Format

Ansible uses an INI-style configuration.

* Full-line comments can start with `#` or `;`
* Inline comments only support `;`

## Generate an Example Configuration

You can create a template configuration with:

```bash
ansible-config init --disabled > ansible.cfg
ansible-config init --disabled -t all > ansible.cfg
```

These templates help you create a consistent project configuration.

## Security Notes

Ansible blocks the use of `ansible.cfg` files located in world-writable directories.
If your workflow relies on a project-level config file, make sure the directory has restricted permissions.
On systems like Vagrant or WSL, adjust mount options when traditional Unix permissions do not apply.

---

# Project Configuration Overview

**File:** `ansible.cfg`
**Scope:** Defines project-level behavior for automation and provisioning.

This section explains how the configuration is organized, why it is structured this way, and how it behaves across environments. It is written for operators, engineers, and auditors.

The goals are:

* Consistent behavior across all environments
* Predictable and secure execution
* Optimized performance on large inventories
* Full project-level isolation

---

# 1. Overview

The configuration defines behavior for:

* Execution performance
* Inventory and fact processing
* SSH and WinRM connections
* Plugin, role, and collection paths
* Output formatting
* Logging and diagnostics
* Privilege escalation

A central configuration ensures stable automation everywhere.

---

# 2. Defaults

The `[defaults]` section defines global settings applied to every run.

## 2.1 Path Configuration

All paths for plugins, roles, and inventory files target project directories. This gives you:

* Reproducible runs
* Isolation from system-level or user-level settings
* Compatibility with CI runners

## 2.2 Execution and Performance

### Forks

`forks = 20` increases concurrency for multi-host deployments with controlled load.

### Pipelining

`pipelining = true` reduces SSH overhead and improves speed.

### Timeouts

Timeouts prevent runs from hanging, making failures predictable.

## 2.3 Error Handling

The config is tuned for large inventories:

* A single host error does not stop the run
* `max_fail_percentage = 0` ensures you see all failures

## 2.4 Output Formatting

YAML output makes logs easier to read in CI and reports.
Deprecation warnings are hidden to keep logs clean.

## 2.5 Python Interpreter Selection

`interpreter_python = auto_silent` selects the appropriate interpreter without printing warnings.

---

# 3. Inventory Configuration

The `[inventory]` section manages host discovery and caching.

## 3.1 Inventory Caching

Caching speeds up repeated runs and reduces load on dynamic sources.

## 3.2 Plugin Control

Only approved inventory plugins are loaded for better security.

## 3.3 Fact Caching

Fact caching improves performance and uses project-local directories for reproducibility.

---

# 4. Privilege Escalation

`become = true` with `sudo` provides consistent elevation.
Environment preservation (`-HE`) supports tasks that require environment variables.

---

# 5. SSH Connection

## 5.1 Multiplexing

ControlMaster and ControlPersist reduce unnecessary SSH handshakes.
Sockets are stored under `~/.ssh/ansible` for easier audits.

## 5.2 Transfer Method

`ssh_transfer_method = piped` improves speed and avoids temp files.

---

# 6. Persistent Connections

Persistent connections improve performance during long operations.
Timeouts keep sessions from hanging.

---

# 7. Windows WinRM Configuration

## 7.1 Secure Transport

The config uses safe defaults, validated certificates, and secure transports.

## 7.2 Timeouts

Values are tuned to allow Windows systems to respond without stalling.

## 7.3 Certificate Trust Path

A consistent trust path ensures correct certificate handling.

---

# 8. Galaxy Configuration

Local role and collection paths guarantee consistent dependency behavior and support offline or CI builds.
TLS validation remains active for secure downloads.

---

# 9. Color Configuration

Color support improves log readability during troubleshooting.

---

# 10. Summary

This configuration provides:

* Predictable and stable automation
* Clear security and privilege rules
* Scalable performance
* Consistent behavior across systems
* Clean and readable output

It supports automation in both engineering and compliance environments.

---

# Auditing Your Ansible Configuration

A guide for enterprise compliance

This section explains how to validate the configuration for security, correctness, and reproducibility.

---

# 1. Audit Scope

Audits verify that:

* The correct config file loads
* Security rules are applied
* Output is consistent
* No sensitive data is leaked
* No unexpected overrides exist

---

# 2. Validate Location and Load Behavior

Run:

```bash
ansible-config view
```

Confirm it matches the committed file.

Then check active values:

```bash
ansible-config dump
```

Verify no system or user overrides appear.

---

# 3. Validate Syntax

Run:

```bash
ansible-config validate
```

The config should pass without warnings.
Ensure no deprecated options remain.

---

# 4. Reproducibility Requirements

Confirm:

* `interpreter_python = auto_silent`
* `retry_files_enabled = False`
* `stdout_callback = yaml`
* All paths reference project directories

These settings guarantee consistent results across machines and environments.

---

# 5. Logging Controls

Verify:

* `log_path` is set
* Logs are collected as CI artifacts
* Sensitive data never appears in logs
* Skipped hosts and task arguments stay hidden

---

# 6. Security Controls

Check that:

* Vault identities are documented
* Sudo settings follow policy
* SSH options match internal standards
* WinRM uses secure transports and validated certificates

---

# 7. SSH Connection Audit

Confirm:

* Multiplexing is active
* Secure transfer methods are used
* No deprecated SSH options are present

---

# 8. Windows WinRM Audit

Ensure:

* Only approved transports are used
* Certificate validation is active
* Timeouts match policy requirements
* Python WinRM dependencies exist in CI

---

# 9. Execution Environment Controls

Check:

* Fork values comply with standards
* Timeouts are documented
* Callback plugins are approved

---

# 10. Plugin Directory Audit

Verify the presence and proper use of:

* `library`
* `roles_path`
* `lookup_plugins`
* `variable_plugins`
* `filter_plugins`

Remove unused directories to prevent drift.

---

# 11. CI Compliance Checklist

* [ ] `ansible-config view` matches the repository
* [ ] Passes `ansible-config validate`
* [ ] No system overrides
* [ ] Logs archived in CI
* [ ] No secrets in config
* [ ] Vault identities documented
* [ ] SSH and WinRM settings compliant
* [ ] Retry files disabled
* [ ] Approved output callback
* [ ] All teams use the same configuration

---

# 12. Common Findings

Frequent issues include:

* Missing directories
* Deprecated SSH flags
* Old leftover settings
* Inconsistent WinRM parameters
* Vault configuration drift

Resolve by updating the config and documenting changes.

---

# 13. Governance

All updates must be reviewed by:

* The automation team
* The security team
* The platform team

CI validates changes automatically.
Each change needs a clear reason in the pull request.

---

# 14. Final Verification

Before approval:

* Test on Linux, macOS, and CI
* Verify plugin paths
* Validate vault settings
* Review logs from staging
* Confirm all teams use the latest version

Once completed, the configuration meets enterprise compliance.
