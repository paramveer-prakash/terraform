provider "aws" {
  region = "ap-south-1"
}
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name="dev-us-east-1-masterproject-igw"
    }
}