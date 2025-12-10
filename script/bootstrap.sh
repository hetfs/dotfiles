#!/usr/bin/env bash
set -euo pipefail

if [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM="macos"
elif grep -qi arch /etc/os-release; then
        PLATFORM="arch"\else
        PLATFORM="ubuntu"
fi

if command -v ansible-playbook >/dev/null; then
        ansible-playbook ansible/playbooks/$PLATFORM/main.yml -i localhost, --connection=local
fi

chezmoi apply
