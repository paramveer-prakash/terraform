provider "aws" {
  region = "ap-south-1"
}

resource "aws_ecr_repository" "my_ecr_repo" {
  name = "masterproject/api-core"

  tags = {
    Name="dev-ap-south-1-ecr"
  }
}