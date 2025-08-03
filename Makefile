# Project config
ANSIBLE_CONFIG := ansible/ansible.cfg
ANSIBLE_DIR := ansible
CHEZMOI_DIR := chezmoi
ENV_FILE := .env

# Optional docker test image (Ubuntu-based for now)
DOCKER_IMAGE := ghcr.io/ansible/ansible-runner

# Load .env if it exists
ifneq ("$(wildcard $(ENV_FILE))","")
  include $(ENV_FILE)
  export
endif

.DEFAULT_GOAL := help

.PHONY: help check-tools bootstrap lint deps provision dry-run syntax-check chezmoi-init chezmoi-apply clean docker-test ubuntu arch mac windows wsl

help:  ## Show all available commands
	@echo ""
	@echo "🛠  Dotfiles Automation Makefile"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'
	@echo ""

check-tools:  ## ✅ Check required tools are installed
	@command -v ansible > /dev/null || (echo "❌ ansible not found!"; exit 1)
	@command -v chezmoi > /dev/null || (echo "❌ chezmoi not found!"; exit 1)
	@command -v python3 > /dev/null || (echo "❌ python3 not found!"; exit 1)
	@command -v pip > /dev/null || (echo "❌ pip not found!"; exit 1)
	@echo "✅ All tools present."

bootstrap: check-tools chezmoi-init deps  ## 🔧 Bootstrap dotfiles and dependencies

chezmoi-init:  ## 🧩 Initialize chezmoi
	chezmoi init --source "$(CHEZMOI_DIR)"

chezmoi-apply:  ## 🎯 Apply chezmoi-managed dotfiles
	chezmoi apply

deps:  ## 📦 Install Ansible Galaxy roles and collections
	cd $(ANSIBLE_DIR) && \
	find playbooks -name requirements.yml -exec ansible-galaxy install -r {} \;

lint:  ## 🧹 Run ansible-lint
	ansible-lint $(ANSIBLE_DIR)/playbooks/ -x 204

provision:  ## 🚀 Run full provisioning
	ansible-playbook $(ANSIBLE_DIR)/site.yml

dry-run:  ## 🔍 Run playbook in check mode
	ansible-playbook $(ANSIBLE_DIR)/site.yml --check --diff

syntax-check:  ## ✅ Validate playbook syntax
	ansible-playbook $(ANSIBLE_DIR)/site.yml --syntax-check

clean:  ## 🧽 Clean cached facts and retry files
	rm -rf $(ANSIBLE_DIR)/.retry/
	rm -rf $(ANSIBLE_DIR)/cache/facts/

docker-test:  ## 🐳 Run Ansible playbook test in Docker
	docker run --rm -v $$PWD:/workspace -w /workspace \
		-e ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) \
		$(DOCKER_IMAGE) \
		ansible-playbook $(ANSIBLE_DIR)/site.yml --check --diff

# OS-specific shortcut targets
ubuntu:  ## 🐧 Test Ubuntu provisioning
	ansible-playbook $(ANSIBLE_DIR)/playbooks/ubuntu/main.yml

arch:  ## 🧪 Test Arch provisioning
	ansible-playbook $(ANSIBLE_DIR)/playbooks/arch/main.yml

mac:  ## 🍏 Test macOS provisioning
	ansible-playbook $(ANSIBLE_DIR)/playbooks/darwin/main.yml

windows:  ## 🪟 Test Windows provisioning
	ansible-playbook $(ANSIBLE_DIR)/playbooks/windows/main.yml

wsl:  ## 💻 Test WSL-specific provisioning
	ansible-playbook $(ANSIBLE_DIR)/playbooks/wsl/main.yml
