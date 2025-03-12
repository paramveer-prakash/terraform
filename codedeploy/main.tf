provider "aws" {
  region = "ap-south-1" # Change this to your preferred AWS region
}

# IAM Role for CodeDeploy
resource "aws_iam_role" "codedeploy_role" {
  name = "CodeDeployServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}

# Attach Policies to the CodeDeploy Role
resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

# Create the CodeDeploy Application
resource "aws_codedeploy_app" "app" {
  name = "MyApp"
  compute_platform = "Server"
}

# Create a CodeDeploy Deployment Group
resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name              = aws_codedeploy_app.app.name
  deployment_group_name = "MyAppGroup"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "Appserver"  # Ensure your EC2 instance has this tag
    }
  }

  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL" # Change to "WITH_TRAFFIC_CONTROL" for Blue/Green
    deployment_type   = "IN_PLACE"
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}
