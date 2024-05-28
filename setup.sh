#!/usr/bin/env bash

apt -qq update
sudo apt install -y aptitude software-properties-common wget curl jq httpie git zip unzip python3-pip build-essential libssl-dev libffi-dev python3-dev python3-distutils

# Create serverip
echo "Creating serverip"
echo "curl -XGET -s https://checkip.amazonaws.com/" >> /usr/local/bin/serverip && echo "echo ''" >> /usr/local/bin/serverip && chmod +x /usr/local/bin/serverip

# Install Docker
echo "Installing docker"
sudo wget -qO- https://get.docker.com | sh

# Create 'clean-docker'
echo "Creating clean-docker"
wget -q https://gist.githubusercontent.com/bondijois/962e203d2b0f74d9b18b87d3c4a287e2/raw/adf0cf25cce11bd4fda1778a15cf9e7e0a52bfeb/clean-docker
mv clean-docker /usr/local/bin/ && chmod +x /usr/local/bin/clean-docker