
# Dotfiles Repository

This repository contains my dotfiles, managed by Chezmoi.

Welcome to my dotfiles repository! This repository contains my personal configuration files and scripts, designed to streamline my development environment across multiple platforms, including **Windows**, **Linux**, and **macOS**.

## Features

- **Cross-Platform Compatibility**: Leveraging tools like **chezmoi** for seamless synchronization and automatic adjustments based on the operating system.
- **Custom Configurations**: Tailored settings for various tools, including shell environments, text editors, and terminal emulators.
- **Version Control**: All configurations are tracked in Git, allowing for easy management of changes and rollbacks.
- **Dynamic Templates**: Utilizing Lua and template systems to create configurations that adapt to different setups.

## Directory Structure

- `shell/` - Contains my shell configurations like `.bashrc`, `.bash_profile`, and `.bash_aliases`.
- `editor/` - Contains configuration for Vim (`.vimrc`) and VSCode (`settings.json`).
- `git/` - Git-related configurations like `.gitconfig` and `.gitignore`.

## Getting Started

To clone and apply my configurations, simply run:

```bash
chezmoi init https://github.com/yourusername/dotfiles.git
chezmoi apply
```

Feel free to explore and adapt these configurations for your own development needs!
