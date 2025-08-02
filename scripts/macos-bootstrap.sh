#!/usr/bin/env bash
# macOS bootstrap script

set -euo pipefail

# Install chezmoi if missing
if ! command -v chezmoi >/dev/null; then
  bin_dir="$HOME/.local/bin"
  chezmoi="$bin_dir/chezmoi"
  sh -c "$(curl -fsLS https://chezmoi.io/get)" -- -b "$bin_dir"
else
  chezmoi=chezmoi
fi

# Apply dotfiles
$chezmoi init --apply https://github.com/hetfs/dotfiles.git

# Install Ansible if missing
if ! command -v ansible >/dev/null; then
  # Install pip if missing
  if ! command -v pip3 >/dev/null; then
    curl -O https://bootstrap.pypa.io/get-pip.py
    python3 get-pip.py --user
    rm get-pip.py
  fi

  pip3 install --user ansible
fi

# Add user bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Install role dependencies
cd dotfiles/ansible
ansible-galaxy install -r playbooks/darwin/requirements.yml

# Execute playbook
ansible-playbook playbooks/darwin/main.yml
