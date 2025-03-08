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