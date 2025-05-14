variable "project_name" {
  type        = string
  description = "Prefix for ECS cluster and services"
}

variable "ecr_repo_url" {
  type        = string
  description = "URL of the container image in ECR"
}

variable "task_exec_role_arn" {
  type        = string
  description = "IAM role ARN for ECS task execution"
}

variable "container_port" {
  type        = number
  description = "Port the container listens on"
}