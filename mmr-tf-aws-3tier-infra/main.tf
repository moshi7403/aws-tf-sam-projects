module "vpc" {
  source  = "./modules/vpc"
  project = var.project
}

module "iam" {
  source  = "./modules/iam"
  project = var.project
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

module "s3" {
  source    = "./modules/s3"
  project   = var.project
  bucket_id = random_id.bucket_id.hex
}

module "ec2" {
  source                = "./modules/ec2"
  project               = var.project
  instance_type         = var.instance_type
  subnet_id             = module.vpc.public_subnet_id
  instance_profile_name = module.iam.instance_profile_name
  vpc_id                = module.vpc.vpc_id
  key_name              = "mosh-iam-admin-keypair"
}