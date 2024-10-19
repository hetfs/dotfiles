# Dotfiles using Chezmoi

Welcome to my dotfiles repository! Here, you'll find my personal configuration files and scripts, meticulously crafted to optimize and unify my development environment across **Windows**, **Linux**, and **macOS**. This repository serves as a central hub for the tools I use daily, helping to streamline my workflow and ensure consistency across platforms.

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

---

## Tools

- [bat](https://github.com/sharkdp/bat) - A cat(1) clone with wings
- [delta](https://github.com/dandavison/delta) - A viewer for git and diff output
- [fd](https://github.com/sharkdp/fd) - A simple, fast and user-friendly alternative to 'find'
- [Nushel](https://www.nushell.sh/) - Easy to extend Nu using a powerful plugin system.
- [fzf](https://github.com/junegunn/fzf) - 🌸 A command-line fuzzy finder
- [glow](https://github.com/charmbracelet/glow) - Render markdown on the CLI, with pizzazz! 💅🏻
- [jq](https://github.com/stedolan/jq) - Command-line JSON processor
- [lazygit](https://github.com/jesseduffield/lazygit) - simple terminal UI for git commands
- [lsd](https://github.com/Peltoche/lsd) - The next gen ls command
- [ripgrep](https://github.com/BurntSushi/ripgrep) - ripgrep recursively searches directories for a regex pattern
- [WezTerm](https://github.com/wez/wezterm) - A GPU-accelerated cross-platform terminal emulator and multiplexer

## Fonts

I use the [JetBrains Mono](https://www.jetbrains.com/lp/mono/) which is a beautiful font designed for developers. It has all sorts of fun features, ligatures, and powerline symbols.

chezmoi's documentation is at [chezmoi.io](https://chezmoi.io/).

Feel free to explore and adapt these configurations for your own development needs!
