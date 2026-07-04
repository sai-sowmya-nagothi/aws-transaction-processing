resource "aws_ecr_repository" "app" {
  name                 = "transaction-processing-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "transaction-processing-app"
    Project = "aws-transaction-processing"
  }
}

resource "aws_ecs_cluster" "main" {
  name = "transaction-processing-cluster"

  tags = {
    Name    = "transaction-processing-cluster"
    Project = "aws-transaction-processing"
  }
}

