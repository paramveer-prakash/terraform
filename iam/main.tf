provider "aws" {
  region = "ap-south-1"
}

resource "aws_iam_user" "myUser" {
  name = "PP"
}

resource "aws_iam_policy" "cusomPolicy" {
 name="GlacierEFSEC2" 
 policy = <<EOF
    {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::*",
        "arn:aws:s3:::*/*"
      ]
    }
  ]
}
 EOF
}


resource "aws_iam_policy_attachment" "policyBind" {
  name="attachment"
  users = [aws_iam_user.myUser.name]
  policy_arn = aws_iam_policy.cusomPolicy.arn
}