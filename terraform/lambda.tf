data "archive_file" "csv_processor" {
  type        = "zip"
  source_file = "${path.module}/../lambda/csv_processor.py"
  output_path = "${path.module}/csv_processor.zip"
}

resource "aws_cloudwatch_log_group" "csv_processor" {
  name              = "/aws/lambda/transaction-csv-processor"
  retention_in_days = 7
}

resource "aws_lambda_function" "csv_processor" {
  function_name = "transaction-csv-processor"
  role          = aws_iam_role.csv_processor_lambda.arn
  handler       = "csv_processor.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.csv_processor.output_path
  source_code_hash = data.archive_file.csv_processor.output_base64sha256

  timeout     = 60
  memory_size = 256

  environment {
    variables = {
      STATE_MACHINE_ARN = aws_sfn_state_machine.transaction_processing.arn
    }
  }

  depends_on = [
    aws_iam_role_policy.csv_processor_lambda,
    aws_cloudwatch_log_group.csv_processor
  ]
}
