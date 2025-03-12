provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "webserver" {
  ami             = "ami-0d682f26195e9ec0f"
  instance_type   = "t2.medium"
  #subnet_id       = aws_subnet.public[0].id
  security_groups = [aws_security_group.web_traffic.name]
  key_name        = "dev-ap-south-1-keypair"
  user_data = file("server-script-docker.sh")
  iam_instance_profile   = aws_iam_instance_profile.codedeploy_instance_profile.name

  tags = {
    Name = "Appserver"
  }
}

resource "aws_eip" "web_ip" {
  instance = aws_instance.webserver.id
}

variable "ingress" {
  type = list(number)
  default = [ 80,443,22,8080,4200]
}

variable "egress" {
  type = list(number)
  default = [ 80,443,22,8080,4200,27017]
}

resource "aws_security_group" "web_traffic" {
  name = "Allow Web Traffic"

  dynamic "ingress" {
    iterator = port
    for_each = var.ingress
    content {
      from_port = port.value
      to_port = port.value
      protocol = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    iterator = port
    for_each = var.egress
    content {
      from_port = port.value
      to_port = port.value
      protocol = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

resource "aws_iam_role" "codedeploy_role" {
  name = "CodeDeployEC2Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach Policies to the IAM Role
resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_iam_role_policy_attachment" "s3_readonly_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Create an Instance Profile
resource "aws_iam_instance_profile" "codedeploy_instance_profile" {
  name = "CodeDeployEC2InstanceProfile"
  role = aws_iam_role.codedeploy_role.name
}


output "PublicIP" {
  value = aws_eip.web_ip.public_ip
}