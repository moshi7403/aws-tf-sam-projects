module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
}

module "ecs" {
  source           = "./modules/ecs"
  project_name     = var.project_name
  container_port   = var.container_port
  ecr_repo_url     = module.ecr.repository_url
  task_exec_role_arn = module.iam.ecs_task_execution_role_arn
}

module "ssm" {
  source       = "./modules/ssm"
  project_name = var.project_name
}

module "codepipeline" {
  source                = "./modules/codepipeline"
  project_name          = var.project_name
  github_owner          = var.github_owner
  github_repo           = var.github_repo
  github_branch         = var.github_branch
  ecs_service_name      = module.ecs.service_name
  ecs_cluster_name      = module.ecs.cluster_name
  container_name        = module.ecs.container_name
  container_port        = var.container_port
  task_definition_arn   = module.ecs.task_definition_arn
  task_exec_role_arn    = module.iam.ecs_task_execution_role_arn
  ecr_repo_url          = module.ecr.repository_url
  github_token = "xxx"
}