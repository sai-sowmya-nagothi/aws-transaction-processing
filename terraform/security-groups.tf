resource "aws_security_group" "ec2" {
  name        = "transaction-processing-ec2-sg"
  description = "Security group for preprocessing EC2 instance"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "transaction-processing-ec2-sg"
    Project = "aws-transaction-processing"
  }
}

resource "aws_security_group" "ecs" {
  name        = "transaction-processing-ecs-sg"
  description = "Security group for ECS processing task"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "transaction-processing-ecs-sg"
    Project = "aws-transaction-processing"
  }
}
