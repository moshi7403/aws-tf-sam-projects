# 🚀 Serverless Web App (API Gateway → Lambda → DynamoDB)

## 🎯 Purpose

This project demonstrates how to deploy a **simple serverless backend** using AWS services with Terraform. It mimics a real-world IoT/toll use case where sensor data (e.g., vehicle transponders) is sent to an API, processed by a Lambda function, and stored in DynamoDB.

You’ll learn how to:
- Create a RESTful endpoint using **API Gateway**
- Deploy and manage a **Lambda function**
- Connect to **DynamoDB** with IAM-secured access
- Use **modular Terraform** for production-ready infrastructure

---

## 🏗️ Folder Structure

```bash
serverless-api/
├── main.tf
├── providers.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── lambda_function/
│   └── index.js
└── modules/
    ├── dynamodb/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── lambda/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── apigateway/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf

## 🧪 Test the API Endpoint

Once the infrastructure is deployed, test the `/vehicle` POST endpoint using `curl`.

### 🔹 Example:

```bash
curl -X POST https://rwpizxxxx.execute-api.us-east-1.amazonaws.com/vehicle \
  -H "Content-Type: application/json" \
  -d '{"transponderId": "TX1001", "location": "Gate-7"}'

## 📦 Zip Your Lambda Code Before Deploying

If you're updating your `index.js` or not using Terraform's built-in archiver, you must manually zip the Lambda function before applying Terraform.

### 🔹 Command:
```bash
cd lambda_function
zip -r ../lambda.zip .
cd ..