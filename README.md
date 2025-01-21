# Project Directory Overview

This directory contains multiple projects and resources for deployment and infrastructure management. The following subdirectories are included:

1. **sam**: Contains projects related to AWS Serverless Application Model (SAM).
2. **terraform**: Contains Terraform scripts for infrastructure as code.

## Navigating the Directory

To navigate to specific directories, use the following commands:

### Change to the `sam` Directory
```bash
cd sam
```

### Change to the `terraform` Directory
```bash
cd terraform
```

## Deployment Instructions

### Deploying SAM Projects

1. Navigate to the `sam` directory:
   ```bash
   cd sam
   ```
2. Install required dependencies (if any):
   ```bash
   npm install
   ```
3. Package the SAM application:
   ```bash
   sam package \
       --template-file template.yaml \
       --s3-bucket <YOUR_S3_BUCKET_NAME> \
       --output-template-file packaged-template.yaml
   ```
4. Deploy the SAM application:
   ```bash
   sam deploy \
       --template-file packaged-template.yaml \
       --stack-name <YOUR_STACK_NAME> \
       --capabilities CAPABILITY_IAM
   ```
5. Delete the SAM stack:
   ```bash
   sam delete
   ```

### Deploying Terraform Configurations

1. Navigate to the `terraform` directory:
   ```bash
   cd terraform
   ```
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Review the execution plan:
   ```bash
   terraform plan
   ```
4. Apply the Terraform configuration to deploy resources:
   ```bash
   terraform apply
   ```
5. Apply changes to a specific target:
   ```bash
   terraform apply -target=<RESOURCE_NAME>
   ```
6. Destroy resources automatically without confirmation:
   ```bash
   terraform destroy --auto-approve
   ```
7. Get help for the `terraform apply` command:
   ```bash
   terraform apply -help
   ```
8. Use `-Y` option with `terraform apply` (if supported):
   ```bash
   terraform apply -Y
   ```

## Additional Notes

- Replace placeholders like `<YOUR_S3_BUCKET_NAME>` and `<YOUR_STACK_NAME>` with actual values specific to your environment.
- Ensure you have the necessary permissions and tools installed, such as AWS CLI for SAM and Terraform CLI for Terraform.
- For detailed information about individual projects, refer to the respective project directories.

## Prerequisites

- **AWS CLI**: [Install AWS CLI](https://aws.amazon.com/cli/).
- **SAM CLI**: [Install SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html).
- **Terraform CLI**: [Install Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

---

Feel free to reach out to the team for additional support or clarification on the deployment process.

