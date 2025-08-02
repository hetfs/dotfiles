#!/usr/bin/env bash
# Full system bootstrap script

set -euo pipefail

# Install chezmoi if missing
if ! command -v chezmoi >/dev/null; then
  sh -c "$(curl -fsLS get.chezmoi.io)"
fi

# Apply dotfiles
chezmoi init --apply https://github.com/hetfs/dotfiles.git

# Install Ansible if missing
if ! command -v ansible >/dev/null; then
  if [ -f /etc/debian_version ]; then
    sudo apt update && sudo apt install -y ansible
  elif [ -f /etc/redhat-release ]; then
    sudo dnf install -y ansible-core
  elif [ "$(uname)" == "Darwin" ]; then
    brew install ansible
  fi
fi

# Install role dependencies
cd ansible
find playbooks -name requirements.yml -exec ansible-galaxy install -r {} \;

# Detect OS and run appropriate playbook
case "$(uname -s)" in
Linux*)
  if [ -f /etc/arch-release ]; then
    PLAYBOOK="arch"
  else
    PLAYBOOK="ubuntu"
  fi
  ;;
Darwin*) PLAYBOOK="darwin" ;;
*)
  echo "Unsupported OS"
  exit 1
  ;;
esac

# Execute playbook
ansible-playbook "playbooks/${PLAYBOOK}/main.yml" --ask-become-pass
