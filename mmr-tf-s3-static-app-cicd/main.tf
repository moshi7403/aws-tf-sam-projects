provider "aws" {
  region = "us-east-1"
}

# CodeBuild Project
resource "aws_codebuild_project" "codebuild_project" {
  name         = "MyCodeBuildProject"
  description  = "Build project for static website"
  service_role = aws_iam_role.codebuild_role.arn
  build_timeout = 30                              # minutes

  artifacts {
    type = "S3"
    location = aws_s3_bucket.website_s3_bucket_001.bucket
    packaging = "ZIP"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:5.0"
    type         = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "ENV"
      value = "production"
    }
  }

  source {
    type = "GITHUB"
    location        = "https://github.com/moshi7403/mmr_apps.git"
    buildspec       = "buildspec.yml" # Ensure this file exists in your repo
    git_clone_depth = 1
  }
}

# S3 Bucket for Website
resource "aws_s3_bucket" "website_s3_bucket_001" {
  bucket = "mmr-static-website-artifact-bucket-001"
}

# S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_s3_bucket_001.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# S3 Public Access Block
resource "aws_s3_bucket_public_access_block" "website_s3_bucket_access_block" {
  bucket = aws_s3_bucket.website_s3_bucket_001.id

  block_public_acls       = false
  block_public_policy     = true
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 Bucket Policy for Public Access
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_s3_bucket_001.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadForGetBucketObjects"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_s3_bucket_001.arn}/*"
      }
    ]
  })
}

# IAM Policy Document for CodePipeline Role
data "aws_iam_policy_document" "pipeline_permissions" {
  statement {
    sid     = "FullAdminAccess"
    effect  = "Allow"
    actions = ["*"]
    resources = ["*"]
  }
}

# IAM Policy for CodePipeline Role
resource "aws_iam_policy" "pipeline_policy" {
  name        = "PipelinePermissionsPolicy"
  description = "Policy for the CodePipeline role"
  policy      = data.aws_iam_policy_document.pipeline_permissions.json
}

# IAM Role for CodePipeline
resource "aws_iam_role" "pipeline_role" {
  name = "PipelineRole"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach IAM Policy to CodePipeline Role
resource "aws_iam_role_policy_attachment" "pipeline_role_policy_attachment" {
  role       = aws_iam_role.pipeline_role.id
  policy_arn = aws_iam_policy.pipeline_policy.arn
}

# GitHub OAuth token stored in SSM Parameter Store
resource "aws_ssm_parameter" "github_token" {
  name  = "GitHubOAuthToken"
  type  = "String"
  value = var.github_token
}

# CodePipeline Resource
resource "aws_codepipeline" "pipeline" {
  name     = "MyCodePipeline"
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.website_s3_bucket_001.bucket
  }

  stage {
    name = "Source"

    action {
      name             = "GithubSource"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceOutput"]
      run_order        = 1

      configuration = {
        Owner      = "moshi7403"        # Your GitHub username
        Repo       = "mmr_apps"        # Your repository name
        Branch     = "main"            # Your branch name
        OAuthToken = var.github_token  # OAuth token stored in SSM or provided as a variable
      }
    }
  }

  stage {
    name = "Build"

    action {
      category = "Build"
      name     = "CodeBuild"
      version  = "1"
      owner    = "AWS"
      provider = "CodeBuild"
      input_artifacts = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]
      run_order = 1
      configuration = {
        ProjectName = aws_codebuild_project.codebuild_project.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "DeployToS3"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      input_artifacts  = ["BuildOutput"]
      run_order        = 1

      configuration = {
        BucketName = aws_s3_bucket.website_s3_bucket_001.bucket
        Extract    = true
      }
    }
  }
}

# Variable for GitHub OAuth token
variable "github_token" {
  description = "GitHub OAuth Token"
  type        = string
}

# CodeBuild Role
resource "aws_iam_role" "codebuild_role" {
  name = "CodeBuildRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# CodeBuild Role Policy
resource "aws_iam_role_policy" "codebuild_policy" {
  name = "CodeBuildPolicy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "s3:GetObject",
        "s3:PutObject"
      ]
      Resource = [
        "arn:aws:logs:*:*:*",
        "${aws_s3_bucket.website_s3_bucket_001.arn}/*"
      ]
    }
    ]
  })
}
