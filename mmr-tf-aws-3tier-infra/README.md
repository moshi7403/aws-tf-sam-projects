# AWS 3-Tier Infrastructure with Terraform

This project provisions a basic 3-tier infrastructure on AWS using **modular Terraform**. It includes:

- A custom **VPC** with a public subnet
- An **EC2 instance** with IAM role and S3 access
- An **S3 bucket** with versioning and lifecycle policies
- Fully modular Terraform setup for reuse and clarity

---

## 📁 Folder Structure

```bash
aws-3tier-infra/
├── main.tf
├── providers.tf
├── variables.tf
├── terraform.tfvars
├── .gitignore
├── README.md
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   ├── s3/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   ├── iam/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf