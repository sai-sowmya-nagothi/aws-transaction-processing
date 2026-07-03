resource "aws_iam_role_policy" "github_actions" {
  name = "github-actions-transaction-processing-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ec2:*",
          "iam:*",
          "ecs:*",
          "ecr:*",
          "states:*",
          "logs:*"
        ]

        Resource = "*"
      }
    ]
  })
}

