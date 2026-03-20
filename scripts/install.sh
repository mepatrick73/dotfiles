#!/bin/bash
# Bootstrap: installs Ansible and runs the dotfiles playbook
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

sudo dnf install -y ansible
ansible-galaxy collection install -r "$DOTFILES_DIR/ansible/requirements.yml"
ansible-playbook "$DOTFILES_DIR/ansible/site.yml" --ask-become-pass
