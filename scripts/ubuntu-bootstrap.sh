#!/usr/bin/env bash
set -euo pipefail

# Install chezmoi if needed
if ! command -v chezmoi >/dev/null; then
  bin_dir="$HOME/.local/bin"
  sh -c "$(curl -fsLS https://chezmoi.io/get)" -- -b "$bin_dir"
  export PATH="$bin_dir:$PATH"
fi

chezmoi init --apply https://github.com/hetfs/dotfiles.git

# Install Ansible if needed
if ! command -v ansible >/dev/null; then
  sudo apt update && sudo apt install -y python3-pip
  pip3 install --user ansible
fi

export PATH="$HOME/.local/bin:$PATH"

# Run provisioning
cd ~/dotfiles/ansible
ansible-galaxy install -r playbooks/ubuntu/requirements.yml
ansible-playbook playbooks/ubuntu/main.yml
