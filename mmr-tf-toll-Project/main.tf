provider "aws" {
  region = "us-east-1"
}

# S3 Buckets
resource "aws_s3_bucket" "landing_bucket" {
  bucket = "toll-landing-bucket-xyz"
  force_destroy = true
}

resource "aws_s3_bucket" "final_bucket" {
  bucket = "toll-final-bucket-xyz"
  force_destroy = true
}

# IAM Roles
data "aws_iam_policy_document" "firehose_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "firehose_role" {
  name               = "firehose_delivery_role"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
}

data "aws_iam_policy_document" "firehose_policy" {
  statement {
    actions   = ["s3:PutObject", "s3:GetBucketLocation", "s3:ListBucket", "s3:GetObject"]
    resources = [aws_s3_bucket.landing_bucket.arn, "${aws_s3_bucket.landing_bucket.arn}/*"]
  }
}

resource "aws_iam_role_policy" "firehose_policy" {
  name   = "firehose_policy"
  role   = aws_iam_role.firehose_role.id
  policy = data.aws_iam_policy_document.firehose_policy.json
}

# Firehose Delivery Stream
resource "aws_kinesis_firehose_delivery_stream" "firehose_stream" {
  name        = "toll-firehose-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.landing_bucket.arn
  }
}

# Lambda Role
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_firehose_policy" {
  name = "lambda_firehose_policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "firehose:PutRecord"
        ],
        Resource = aws_kinesis_firehose_delivery_stream.firehose_stream.arn
      }
    ]
  })
}

# Firehose Forwarder Lambda
resource "aws_lambda_function" "firehose_forwarder" {
  function_name = "firehose-forwarder-lambda"
  handler       = "index.handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn
  filename      = "${path.module}/lambda/firehose_forwarder/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/firehose_forwarder/lambda.zip")

  environment {
    variables = {
      FIREHOSE_STREAM_NAME = aws_kinesis_firehose_delivery_stream.firehose_stream.name
    }
  }
}

# Post-Processor Lambda
resource "aws_lambda_function" "post_processor" {
  function_name = "post-processing-lambda"
  handler       = "index.handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn
  filename      = "${path.module}/lambda/post_processor/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/post_processor/lambda.zip")
  environment {
    variables = {
      FINAL_BUCKET = aws_s3_bucket.final_bucket.bucket
    }
  }
}

# API Gateway HTTP API
resource "aws_apigatewayv2_api" "http_api" {
  name          = "toll-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.firehose_forwarder.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /data"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# Allow API Gateway to invoke Lambda
resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.firehose_forwarder.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# Allow S3 to invoke Post-Processor Lambda
resource "aws_s3_bucket_notification" "landing_bucket_notify" {
  bucket = aws_s3_bucket.landing_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.post_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.landing_bucket.arn
}