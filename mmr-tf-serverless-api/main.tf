resource "random_id" "suffix" {
  byte_length = 4
}

module "dynamodb" {
  source     = "./modules/dynamodb"
  table_name = "vehicles-${random_id.suffix.hex}"
}

module "lambda" {
  source         = "./modules/lambda"
  function_name  = "store-vehicle-data-${random_id.suffix.hex}"
  table_name     = module.dynamodb.table_name
  table_arn      = module.dynamodb.table_arn
  handler        = "index.handler"
  runtime        = "nodejs18.x"
  source_path    = "${path.module}/lambda_function"
}

module "apigateway" {
  source         = "./modules/apigateway"
  lambda_arn     = module.lambda.lambda_arn
  lambda_name    = module.lambda.lambda_name
  api_name       = "vehicle-api-${random_id.suffix.hex}"
}