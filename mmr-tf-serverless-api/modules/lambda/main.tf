data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.source_path
  output_path = "${path.module}/lambda.zip"
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_dynamo_policy" {
  name       = "${var.function_name}-policy"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role          = aws_iam_role.lambda_exec.arn
  handler       = var.handler
  runtime        = "nodejs16.x"              # 👈 hardcoded here
  timeout          = 10  # 👈 Add this line

  environment {
    variables = {
      TABLE_NAME = var.table_name
    }
  }
}

resource "aws_iam_policy_attachment" "lambda_logging" {
  name       = "${var.function_name}-logs"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}