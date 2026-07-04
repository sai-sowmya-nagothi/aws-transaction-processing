resource "aws_sfn_state_machine" "transaction_processing" {
  name     = "transaction-processing-workflow"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = jsonencode({
    Comment = "Check and validate EC2 before running ECS transaction task"

    StartAt = "CheckEC2Instance"

    States = {

      CheckEC2Instance = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:ec2:describeInstances"

        Parameters = {
          InstanceIds = [
            "i-0dcf53b90a7bf8281"
          ]
        }

        ResultPath = "$.EC2Check"
        Next       = "IsEC2Running"
      }

      IsEC2Running = {
        Type = "Choice"

        Choices = [
          {
            Variable     = "$.EC2Check.Reservations[0].Instances[0].State.Name"
            StringEquals = "running"
            Next         = "RunTransactionTask"
          },
          {
            Variable     = "$.EC2Check.Reservations[0].Instances[0].State.Name"
            StringEquals = "stopped"
            Next         = "StartEC2Instance"
          }
        ]

        Default = "EC2ValidationFailed"
      }

      StartEC2Instance = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:ec2:startInstances"

        Parameters = {
          InstanceIds = [
            "i-0dcf53b90a7bf8281"
          ]
        }

        ResultPath = "$.EC2StartResult"
        Next       = "WaitForEC2"
      }

      WaitForEC2 = {
        Type    = "Wait"
        Seconds = 30
        Next    = "ValidateEC2Running"
      }

      ValidateEC2Running = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:ec2:describeInstances"

        Parameters = {
          InstanceIds = [
            "i-0dcf53b90a7bf8281"
          ]
        }

        ResultPath = "$.EC2Validation"
        Next       = "IsEC2Ready"
      }

      IsEC2Ready = {
        Type = "Choice"

        Choices = [
          {
            Variable     = "$.EC2Validation.Reservations[0].Instances[0].State.Name"
            StringEquals = "running"
            Next         = "RunTransactionTask"
          }
        ]

        Default = "EC2ValidationFailed"
      }

      RunTransactionTask = {
        Type     = "Task"
        Resource = "arn:aws:states:::ecs:runTask.sync"

        Parameters = {
          Cluster        = aws_ecs_cluster.main.arn
          TaskDefinition = aws_ecs_task_definition.app.arn
          LaunchType     = "FARGATE"

          NetworkConfiguration = {
            AwsvpcConfiguration = {
              Subnets = [
                aws_subnet.public.id
              ]

              SecurityGroups = [
                aws_security_group.ecs.id
              ]

              AssignPublicIp = "ENABLED"
            }
          }

          Overrides = {
            ContainerOverrides = [
              {
                Name = "transaction-processing-app"

                Environment = [
                  {
                    Name      = "TRANSACTION_JSON"
                    "Value.$" = "States.JsonToString($)"
                  }
                ]
              }
            ]
          }
        }

        End = true
      }

      EC2ValidationFailed = {
        Type  = "Fail"
        Error = "EC2ValidationFailed"
        Cause = "EC2 instance is not in running state"
      }
    }
  })
}

