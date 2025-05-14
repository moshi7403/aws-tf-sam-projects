variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "tollapp"
}

variable "github_owner" {
  description = "GitHub username or org"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "Branch to track in CodePipeline"
  type        = string
  default     = "main"
}

variable "container_port" {
  description = "Port your app listens on"
  type        = number
  default     = 80
}