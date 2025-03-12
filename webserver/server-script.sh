#!/bin/bash
sudo apt update
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
echo "<h1>Hello from Terraform by PARAM 1</h1>" | sudo tee /var/www/html/index.html