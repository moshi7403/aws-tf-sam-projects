# TollApp Infrastructure – ECS Fargate CI/CD via Terraform

This project provisions a full CI/CD pipeline on AWS using Terraform, designed to deploy a containerized application (e.g., Python or static HTML) to **ECS Fargate**.

## 🚀 What It Does

- Creates a **private ECR repository** for your container image
- Sets up an **ECS Cluster + Task + Service** using Fargate (no ALB)
- Connects your **GitHub repo** to **CodePipeline**
- Builds the Docker image via **CodeBuild**
- Deploys it to ECS automatically on **Git push**

---

## 🧱 Folder Structure

```bash
cs-ci-cd/
├── main.tf                 # Root orchestrator
├── provider.tf             # AWS provider config
├── variables.tf            # Input variables
├── terraform.tfvars        # Your project-specific values
├── outputs.tf              # Useful outputs
├── modules/
│   ├── ecr/                # Creates ECR repo
│   ├── ecs/                # ECS cluster, task, service (Fargate)
│   ├── iam/                # IAM roles for ECS/CodeBuild
│   ├── codepipeline/       # Pipeline, CodeBuild, S3 artifacts
│   └── ssm/                # Optional env variables in SSM



---

## 🧩 Requirements

- AWS account with appropriate IAM permissions
- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads)
- A GitHub repository with a Dockerfile and app code
- A GitHub Personal Access Token (PAT) with `repo` scope

---

## 🔧 Setup

1. **Clone this repo**:
   ```bash
   git clone https://github.com/your-org/ecs-ci-cd
   cd ecs-ci-cd

## 🔧 Edit terraform.tfvars: 

```bash
aws_region     = "us-east-1"
project_name   = "tollapp-xxxm"
github_owner   = "xxx"
github_repo    = "xxx"
github_branch  = "x"
container_port = x

## 🔧 Add your GitHub token in main.tf or pass it during apply:

terraform apply -var="github_token=ghp_XXXX..."
