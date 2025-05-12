# DynamoDB Table
resource "aws_dynamodb_table" "vehicle_data" {
  name           = "TollVehicleData"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "vehicle_id"
  range_key      = "timestamp"

  attribute {
    name = "vehicle_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }
}

# Lambda to move data from Final S3 to DynamoDB
resource "aws_lambda_function" "s3_to_dynamo" {
  function_name = "s3-to-dynamo-lambda"
  handler       = "index.handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn
  filename      = "${path.module}/lambda/s3_to_dynamo/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/s3_to_dynamo/lambda.zip")

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.vehicle_data.name
    }
  }
}

# S3 notification on final bucket to trigger this Lambda
resource "aws_s3_bucket_notification" "final_bucket_notify" {
  bucket = aws_s3_bucket.final_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_to_dynamo.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }
}

# Lambda permission for S3 to invoke it
resource "aws_lambda_permission" "allow_s3_final_to_invoke" {
  statement_id  = "AllowS3InvokeFinal"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_to_dynamo.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.final_bucket.arn
}