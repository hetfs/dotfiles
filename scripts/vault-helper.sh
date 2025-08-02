# File: scripts/vault-helper.sh
#!/bin/bash
# Automated vault handling for different environments

ENVIRONMENT=${1:-development}

case $ENVIRONMENT in
production)
  VAULT_FILE="secrets/ansible-vault/prod.yml"
  ;;
staging)
  VAULT_FILE="secrets/ansible-vault/staging.yml"
  ;;
*)
  VAULT_FILE="secrets/ansible-vault/dev.yml"
  ;;
esac

ansible-playbook playbooks/$OS/main.yml \
  --vault-password-file ~/.vault_pass \
  --extra-vars "@$VAULT_FILE"
