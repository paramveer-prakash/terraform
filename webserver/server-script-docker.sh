#!/bin/bash
set -euxo pipefail

# Log output to cloud-init logs
exec > /var/log/user-data.log 2>&1

# Update package lists
sudo yum update -y

# Install docker engine
sudo yum install -y docker
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user
newgrp docker

# Install AWS CodeDeploy Agent
echo "Installing AWS CodeDeploy Agent..."
sudo yum update -y
sudo yum install ruby wget -y
cd /home/ec2-user
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo systemctl start codedeploy-agent
sudo systemctl enable codedeploy-agent
