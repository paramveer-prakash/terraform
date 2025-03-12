#!/bin/bash
#!/bin/bash
set -euxo pipefail

# Log output to cloud-init logs
exec > /var/log/user-data.log 2>&1

# Update package lists
sudo yum update -y

# Install required dependencies
sudo yum install -y ca-certificates curl gnupg

# Add Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists again
sudo yum update -y

# Install Docker and required components (force yes)
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker service
sudo systemctl enable --now docker

# Add 'ubuntu' user to 'docker' group (avoid sudo for Docker)
sudo usermod -aG docker ubuntu

# Restart shell to apply group changes
newgrp docker

# Verify installation
docker --version

# Confirm successful installation
echo "Docker has been successfully installed!"


sudo apt install ruby-full -y
sudo apt install wget -y
cd /home/ubuntu
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo systemctl start codedeploy-agent
sudo systemctl enable codedeploy-agent
sudo systemctl status codedeploy-agent

#docker pull nginx:latest

#docker run -d -p 80:80 --name nginx nginx:latest