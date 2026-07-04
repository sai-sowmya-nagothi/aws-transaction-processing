# ============================================================
# GitHub Actions OIDC Provider
# ============================================================

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]

  tags = {
    Name    = "github-actions-oidc"
    Project = "aws-transaction-processing"
  }
}


# ============================================================
# GitHub Actions IAM Role
# ============================================================

resource "aws_iam_role" "github_actions" {
  name = "github-actions-transaction-processing-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:sai-sowmya-nagothi/aws-transaction-processing:ref:refs/heads/main"
          }
        }
      }
    ]
  })

  tags = {
    Name    = "github-actions-transaction-processing-role"
    Project = "aws-transaction-processing"
  }
}


# ============================================================
# ECS Task Execution Role
# ============================================================

resource "aws_iam_role" "ecs_task_execution" {
  name = "transaction-processing-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "transaction-processing-ecs-task-execution-role"
    Project = "aws-transaction-processing"
  }
}


# ============================================================
# Attach AWS ECS Execution Policy
# ============================================================

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# ============================================================
# Step Functions IAM Role
# IMPORTANT: Name matches step-functions.tf reference
# aws_iam_role.step_functions_role.arn
# ============================================================

resource "aws_iam_role" "step_functions_role" {
  name = "transaction-processing-step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "states.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "transaction-processing-step-functions-role"
    Project = "aws-transaction-processing"
  }
}


# ============================================================
# Step Functions Permissions
# ============================================================

resource "aws_iam_role_policy" "step_functions_policy" {
  name = "transaction-processing-step-functions-policy"
  role = aws_iam_role.step_functions_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "EC2CheckStartValidate"
        Effect = "Allow"

        Action = [
          "ec2:DescribeInstances",
          "ec2:StartInstances"
        ]

        Resource = "*"
      },

      {
        Sid    = "RunECSTask"
        Effect = "Allow"

        Action = [
          "ecs:RunTask",
          "ecs:DescribeTasks",
          "ecs:StopTask"
        ]

        Resource = "*"
      },

      {
        Sid    = "PassECSTaskExecutionRole"
        Effect = "Allow"

        Action = [
          "iam:PassRole"
        ]

        Resource = aws_iam_role.ecs_task_execution.arn
      }
    ]
  })
}
