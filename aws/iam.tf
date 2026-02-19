# Create IAM role for EC2 instance
resource "aws_iam_role" "mongodb-role" {
  name = "mongodb-role-${random_string.random.result}"

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

# Create IAM policy for MongoDB
resource "aws_iam_policy" "policy" {
  name = "mongodb-policy-${random_string.random.result}"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "iam:GetRole",
          "iam:PassRole"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "rds:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.db-bkp.arn}/*"
      }
    ]
  })
}

# Attach IAM policy to IAM role
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.mongodb-role.name
  policy_arn = aws_iam_policy.policy.arn
}

# Create an EC2 instance profile
resource "aws_iam_instance_profile" "mongodb-profile" {
  name = "mongodb-profile-${random_string.random.result}"
  role = aws_iam_role.mongodb-role.name
}