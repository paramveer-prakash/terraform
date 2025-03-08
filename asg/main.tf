provider "aws" {
  region = "ap-south-1"
}

# Define VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MainVPC"
  }
}

# Define a Subnet in VPC
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"  # Change this if needed
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

# Define Auto Scaling Template
resource "aws_launch_template" "webserver_template" {
  name_prefix   = "webserver-template"
  image_id      = "ami-0d682f26195e9ec0f"
  instance_type = "t2.micro"
  key_name      = "dev-ap-south-1-keypair"

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Appserver"
    }
  }
}

# Define Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "webserver_asg" {
  name                      = "webserver-asg"
  min_size                  = 0
  max_size                  = 5
  desired_capacity          = 2
  vpc_zone_identifier       = [aws_subnet.public_subnet.id]
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.webserver_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Appserver"
    propagate_at_launch = true
  }
}
