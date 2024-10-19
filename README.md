# Dotfiles which Chezmoi manages

Welcome to my dotfiles repository! This repository contains my personal configuration files and scripts, designed to streamline my development environment across multiple platforms, including **Windows**, **Linux**, and **macOS**.

## Features

- **Cross-Platform Compatibility**: Leveraging tools like **chezmoi** for seamless synchronization and automatic adjustments based on the operating system.
- **Custom Configurations**: Tailored settings for various tools, including shell environments, text editors, and terminal emulators.
- **Version Control**: All configurations are tracked in Git, allowing for easy management of changes and rollbacks.
- **Dynamic Templates**: Utilizing Lua and template systems to create configurations that adapt to different setups.

## Directory Structure

- `shell/` - Contains my shell configurations like `.bashrc`, `.bash_profile`,`.bash_aliases`, and **clink** configurations.
- `editor/` - Contains configuration for Nevim and  VSCode (`settings.json`).
- `git/` - Git-related configurations like `.gitconfig` and `.gitignore`.

## Getting Started

We need to install chezmoi first and pull the configuration:

```shell
# Initialising chezmoi repository
chezmoi init git@github.com:gwarf/dotfiles.git
# Checking changes
chezmoi diff
# Applying changes
chezmoi apply
```

### Pulling changes

#### Pulling changes and reviewing them

```shell
# Pull latest changes and preview them
chezmoi git pull -- --autostash --rebase && chezmoi diff
# Applying them
chezmoi apply
```

#### Pulling changes and apply them without review

```shell
# Verbosy pull and apply changes
chezmoi update -v
```

### Pushing changes

> If autocomit is enabled in `~/.config/chezmoi/chezmoi.toml`, changes made with `chezmoi edit` are automatically committed and pushed

```shell
# Open repository clone location
chezmoi cd
# Check status
git statusgit diff
# Commit all changes
git commit -a
# Push changes
git push
```

chezmoi's documentation is at [chezmoi.io](https://chezmoi.io/).
Feel free to explore and adapt these configurations for your own development needs!
