#!/bin/bash 
# Install ansible (and optionally brew)

which brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install ansible 
ansible-playbook --ask-sudo-pass install.yml
