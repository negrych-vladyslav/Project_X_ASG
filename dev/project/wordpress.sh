#!/bin/bash
sudo apt update -y
sudo apt install git ansible -y
git clone https://github.com/samanykvlad/ansible.git
cd ansible
ansible-playbook wordpress.yml

