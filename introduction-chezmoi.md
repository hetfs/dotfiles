# Getting Started with chezmoi

[**chezmoi**](https://www.chezmoi.io/) is a powerful command-line tool designed to simplify the management of dotfiles and configuration files across different systems. It ensures a consistent setup on **Windows**, **Linux**, and **macOS**. With **chezmoi**, you can effortlessly maintain a personalized development environment on all your devices, making it ideal for managing configurations and automating synchronization for terminal tools. It even supports scripting integrations, including **Lua**, for system-specific tasks.

## Key Features

- **Git Integration**: Easily sync your configurations using Git to track changes and revert updates across devices.
- **Cross-Platform Compatibility**: Automatically adapts to various operating systems without manual configuration.
- **Dynamic Templating**: Leverage a flexible templating engine to customize configurations based on system variables (such as environment or OS).
- **Effortless Synchronization**: Quickly synchronize configurations across systems with minimal commands.
Installing chezmoi

You can set up dotfiles from a GitHub repository on a new system with **chezmoi** (pronounced /ʃeɪ mwa/ or "shay-mwa") using a single command:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```

> **Note**: On Windows, run `sh` commands using [Git Bash](https://gitforwindows.org/).

Alternatively, install **chezmoi** via a package manager:

**Windows**: Use Chocolatey, Scoop, or Winget.

```powershell
winget install twpayne.chezmoi
```

**Linux (Ubuntu/Debian)**

```bash
sudo apt install chezmoi
```

**macOS**: Install using Homebrew

```bash
brew install chezmoi
```

For more installation options, visit [chezmoi’s installation page](https://www.chezmoi.io/install/).

---

## Getting Started

To begin managing your dotfiles with **chezmoi**, initialize it first:

```bash
chezmoi init
```

This command creates a local Git repository at `~/.local/share/chezmoi` (on Windows, it will be `C:\Users\%USERPROFILE%\.local\share\chezmoi`) to store your dotfiles' source state.

### Example: Adding `.bashrc`

To add `.bashrc` to **chezmoi**:

```bash
chezmoi add ~/.bashrc
```

This copies `.bashrc` to the chezmoi source directory as `~/.local/share/chezmoi/dot_bashrc`. To edit it later:

```bash
chezmoi edit ~/.bashrc
```

After making your edits, preview the changes:

```bash
chezmoi diff
```

To apply the changes, use:

```bash
chezmoi -v apply
```

The `-v` (verbose) flag will show exactly what changes will be made. For a dry run, combine the `-n` and `-v` options.

### Committing Changes

Once you've completed your edits, commit the changes to Git:

```bash
chezmoi cd
git add .
git commit -m "Update dotfiles"
```

---

## Linking chezmoi to Your Dotfile Repository

If you have an existing dotfile repository, link it to **chezmoi** by initializing with:

```bash
chezmoi init --apply https://github.com/$GITHUB_USERNAME/dotfiles.git
```

To push your local dotfiles from the chezmoi source directory to the repository:

```bash
git remote add origin git@github.com:$GITHUB_USERNAME/dotfiles.git
git branch -M main
git push -u origin main
exit
```

> If needed, create a new repository on [GitHub](https://github.com/new). **chezmoi** supports repositories on [GitLab](https://gitlab.com/), [BitBucket](https://bitbucket.org/), and [SourceHut](https://sourcehut.org/).

---

On a new device, clone and apply your dotfiles with:

```bash
chezmoi init https://github.com/$GITHUB_USERNAME/dotfiles.git
chezmoi diff  # Preview changes
chezmoi apply -v # Apply changes
```

For a streamlined setup, use:

```bash
chezmoi init --apply --verbose https://github.com/$GITHUB_USERNAME/dotfiles.git
```

To fetch the latest updates from your repository:

```bash
chezmoi update -v
```

---

## chezmoi Command Overview

### Daily Commands

- [`chezmoi add $FILE`](https://www.chezmoi.io/reference/commands/add/): Adds `$FILE` from your home directory to the source directory for tracking.
- [`chezmoi edit $FILE`](https://www.chezmoi.io/reference/commands/edit/): Opens `$FILE` in your editor, targeting the source directory.
- [`chezmoi status`](https://www.chezmoi.io/reference/commands/status/): Summarizes which files would change if `chezmoi apply` were executed.
- [`chezmoi diff`](https://www.chezmoi.io/reference/commands/diff/): Displays the differences that `chezmoi apply` would make to your home directory.
- [`chezmoi apply`](https://www.chezmoi.io/reference/commands/apply/): Applies updates to your dotfiles from the source directory.
- [`chezmoi edit --apply $FILE`](https://www.chezmoi.io/reference/commands/edit/): Edits `$FILE` and immediately applies the changes.
- [`chezmoi cd`](https://www.chezmoi.io/reference/commands/cd/): Opens a subshell in the source directory.

### Using chezmoi Across Multiple Machines

- [`chezmoi init $GITHUB_USERNAME`](https://www.chezmoi.io/reference/commands/init/): Clones your dotfiles from GitHub into the source directory.
- [`chezmoi init --apply $GITHUB_USERNAME`](https://www.chezmoi.io/reference/commands/init/): Clones dotfiles from GitHub and applies them immediately.
- [`chezmoi update`](https://www.chezmoi.io/reference/commands/update/): Pulls the latest changes from your remote repository and applies them.

### Working with Templates

- [`chezmoi data`](https://www.chezmoi.io/reference/commands/data/): Displays available template data for use in templating files.
- [`chezmoi add --template $FILE`](https://www.chezmoi.io/reference/commands/add/): Adds `$FILE` as a dynamic template for configurations.
- [`chezmoi chattr +template $FILE`](https://www.chezmoi.io/reference/commands/chattr/): Converts an existing file into a template.
- [`chezmoi cat $FILE`](https://www.chezmoi.io/reference/commands/cat/): Displays the target contents of `$FILE` without making changes.
- [`chezmoi execute-template`](https://www.chezmoi.io/reference/commands/execute-template/): Tests and debugs templates by rendering them with current data.
- [`chezmoi doctor`](https://www.chezmoi.io/reference/commands/doctor/): Performs diagnostic checks for common issues, useful for troubleshooting unexpected behavior.

To see a complete list of chezmoi commands, run:

```bash
chezmoi help
```

These commands provide a structured and efficient workflow for managing dotfiles, allowing you to update, sync, and customize configurations seamlessly across multiple environments. You’re now ready to manage and synchronize your dotfiles effortlessly with **chezmoi**!
