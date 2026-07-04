resource "aws_s3_bucket" "transaction_input" {
  bucket_prefix = "transaction-input-"

  tags = {
    Name    = "transaction-input-bucket"
    Project = "aws-transaction-processing"
  }
}

resource "aws_s3_bucket_public_access_block" "transaction_input" {
  bucket = aws_s3_bucket.transaction_input.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "transaction_input_bucket_name" {
  value = aws_s3_bucket.transaction_input.bucket
}
