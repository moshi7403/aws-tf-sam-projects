resource "aws_ssm_parameter" "app_env" {
  name  = "/${var.project_name}/env/ENVIRONMENT"
  type  = "String"
  value = "dev"
}