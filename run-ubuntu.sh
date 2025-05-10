#!/bin/bash 
# Install ansible ppa/ansible and run playbook 

sudo apt-get update && sudo apt-get install -y software-properties-common
sudo apt-add-repository -y ppa:ansible/ansible 
sudo apt-get update && sudo apt-get install -y ansible ansible-core python3

ansible-playbook --ask-become-pass install.yml
