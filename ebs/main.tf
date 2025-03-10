provider "aws" {
  region = "ap-south-1"
}

# 🔹 Create an Elastic Beanstalk Application
resource "aws_elastic_beanstalk_application" "my_app" {
  name        = "my-docker-app"
  description = "Elastic Beanstalk application for Docker"
}

# 🔹 Create an S3 bucket for Elastic Beanstalk deployment files
resource "aws_s3_bucket" "eb_bucket" {
  bucket_prefix = "elastic-beanstalk-app-"
  force_destroy = true
}

# 🔹 Create an Elastic Beanstalk Environment
resource "aws_elastic_beanstalk_environment" "my_env" {
  name                = "my-docker-env"
  application         = aws_elastic_beanstalk_application.my_app.name
  solution_stack_name = "64bit Amazon Linux 2 v4.0.8 running Docker" # Adjust version if needed

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DOCKER_IMAGE"
    value     = "${aws_ecr_repository.my_ecr_repo.repository_url}:latest"
  }

  setting {
    namespace = "aws:elasticbeanstalk:container:docker"
    name      = "ImageUrl"
    value     = "${aws_ecr_repository.my_ecr_repo.repository_url}:latest"
  }
}

# 🔹 Create an ECR Repository
resource "aws_ecr_repository" "my_ecr_repo" {
  name = "masterproject/api-core"
}

# 🔹 Allow Beanstalk to Pull from ECR
resource "aws_iam_role" "eb_instance_role" {
  name = "ElasticBeanstalkInstanceRole"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy_attachment" "eb_instance_policy" {
  name       = "eb-instance-policy"
  roles      = [aws_iam_role.eb_instance_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
