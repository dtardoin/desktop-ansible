#!/bin/bash 
# Install ansible (and optionally brew)

which brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo "$PATH:/opt/homebrew/bin/" >> ~/.zshrc 
source ~/.zshrc
/opt/homebrew/bin/brew install ansible 
/opt/homebrew/bin/ansible-playbook --ask-become-pass --skip-tags ubuntu install.yml
