provider "aws" {
  region = "ap-south-1"
}

variable "aws_region" {
  description = "AWS region"
  default = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Publicc subnet CIDRs"
  type = list(string)
  default = [ "10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type = list(string)
  default = [ "10.0.3.0/24", "10.0.4.0/24" ]
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"  
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
      Name = "dev-ap-south-1-vpc"
    }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    count = length(var.public_subnet_cidrs)
    cidr_block = var.public_subnet_cidrs[count.index]
    map_public_ip_on_launch = true
    availability_zone = element(["ap-south-1a"],count.index)

    tags = {
      Name="Public Subnet ${count.index +1}"
    }
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  count = length(var.public_subnet_cidrs)
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = element(["ap-south-1a"],count.index)

  tags = {
    Name="Private Subnet ${count.index +1}"
  }

}


resource "aws_security_group" "allow_http" {
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Allow HTTP & HTTPS"
    }
  
}

# Create Security Group for Nginx
resource "aws_security_group" "nginx_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP access from anywhere
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH access from anywhere (Change for security)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "nginx-security-group"
  }
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name="dev-us-east-1-masterproject-igw"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
      Name = "Public Route Table"
    }
  
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id = element(aws_subnet.public[*].id,count.index)
  route_table_id = aws_route_table.public.id
}


resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public[0].id

  tags = {
    Name = "Main NAT Gateway"
  }
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.main.id
    }

    tags = {
      Name = "Private Route table"
    }
}

resource "aws_route_table_association" "private" {
    count = length(var.private_subnet_cidrs)
    subnet_id = element(aws_subnet.private[*].id,count.index)
    route_table_id = aws_route_table.private.id
  
}

resource "aws_instance" "nginx_server" {
  ami             = "ami-00bb6a80f01f03502"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public[0].id
  security_groups = [aws_security_group.nginx_sg.name]
  key_name        = "dev-ap-south-1-keypair"

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y nginx
              sudo systemctl enable nginx
              sudo systemctl start nginx
              EOF

  tags = {
    Name = "dev-nginx-instance"
  }
}

output "vpc_id" {
  description = "VPC ID"
  value = aws_vpc.main.id
}

output "public_subnets" {
  description = "List of Public Subnet IDs"
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "List of Private Subnet IDs"
  value = aws_subnet.private[*].id
}