# Create an ECR repo
resource "aws_ecr_repository" "repo" {
  name                 = "my-tasky"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  encryption_configuration {
    encryption_type = "KMS"
  }
}