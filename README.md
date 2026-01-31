# StartTech Infrastructure Deployment with Terraform

This repository contains the Infrastructure as Code (IaC) setup for **StartTech**, a scalable web application deployed on AWS using **Terraform** and automated with **GitHub Actions**.

The infrastructure is designed following cloud best practices, focusing on **high availability**, **scalability**, **security**, and **automation**.

---

## Architecture Overview

The infrastructure provisions and manages the following:

* **Highly available VPC** spanning multiple Availability Zones
* **Public and private subnets** with proper routing
* **Application Load Balancer (ALB)** for backend traffic
* **Auto Scaling Group (ASG)** for backend EC2 instances
* **Dockerized backend application** started automatically via EC2 user data
* **S3 bucket** for frontend static website hosting
* **CloudFront distribution** for global content delivery
* **ElastiCache (Redis)** for caching
* **CloudWatch Log Groups** for application and system logs
* **IAM roles and policies** for EC2 to access AWS services securely
* **Security Groups** for all components
* **SSM Session Manager** for secure, keyless instance access (no SSH required)

---

## Project Structure

```text
starttech-infra/
├── .github/
│   └── workflows/
│       └── infrastructure-deploy.yml
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   └── modules/
│       ├── networking/
│       ├── compute/
│       ├── storage/
│       └── monitoring/
```

### Module Responsibilities

* **Networking module**

  * VPC
  * Public and private subnets
  * Route tables, Internet Gateway, NAT Gateway
  * Security Groups

* **Compute module**

  * Launch Template
  * Auto Scaling Group for backend EC2 instances
  * Application Load Balancer and Target Group
  * User data for Dockerized backend startup

* **Storage module**

  * S3 bucket with static website configuration
  * CloudFront distribution
  * ElastiCache Redis cluster

* **Monitoring module**

  * CloudWatch Log Groups
  * IAM roles and instance profiles for EC2

---

## Prerequisites

Before deploying, ensure you have the following installed and configured:

### 1. Terraform

Download from:
[https://developer.hashicorp.com/terraform/downloads](https://developer.hashicorp.com/terraform/downloads)

Verify installation:

```bash
terraform -v
```

---

### 2. AWS CLI

Install the AWS CLI:
[https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

Verify installation:

```bash
aws --version
```

Configure AWS credentials:

```bash
aws configure
```

You will be prompted for:

* AWS Access Key ID
* AWS Secret Access Key
* Default region (e.g. eu-west-2)
* Output format (optional)

---

### 3. GitHub Secrets & Variables

The GitHub Actions workflow requires the following:

**Secrets**:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `BUCKET` (S3 bucket for Terraform remote state)

**Variables**:

* `AWS_REGION`

---

## Deployment Options

You can deploy the infrastructure in **two ways**:

---

## Option 1: Manual Terraform Deployment

### 1. Clone the repository

```bash
git clone https://github.com/farmerpisco/month-one-assessment.git
cd month-one-assessment/terraform
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Preview the plan

```bash
terraform plan
```

### 4. Apply the infrastructure

```bash
terraform apply
```

Type `yes` when prompted.

---

## Option 2: Automated Deployment with GitHub Actions (Best and Recommended)

Infrastructure deployment is automated using **GitHub Actions**.

### Deployment Trigger

* Any `push` to the `main` branch affecting files under `terraform/`

### What the workflow does

* Checks out the repository
* Sets up Terraform
* Formats and validates Terraform code
* Initializes Terraform with an S3 backend
* Generates and applies an execution plan

### Destroy Trigger

* Manually triggered using `workflow_dispatch`

This ensures:

* Safe, repeatable infrastructure changes
* No manual Terraform execution required

---

## Application Runtime Behavior

* Backend instances are launched via an **Auto Scaling Group**
* A **Launch Template** provides EC2 user data
* User data installs Docker and starts:

  * Backend application container
  * MongoDB container (for assessment/demo purposes)
* Each EC2 instance automatically:

  * Registers with the ALB target group
  * Streams logs to CloudWatch

No backend CI/CD workflow is required for instance startup.

---

## Accessing the Application

After deployment, Terraform outputs include:

* **Application Load Balancer DNS name** – access the backend
* **CloudFront distribution domain** – access the frontend

Backend EC2 instances are accessed securely using:

```bash
aws ssm start-session --target <instance-id>
```

---

## Infrastructure Cleanup

To avoid unnecessary AWS costs, destroy the infrastructure when finished.

### Manual cleanup

```bash
terraform destroy
```

### Automated cleanup

* Trigger the **Destroy Infra on AWS** job using GitHub Actions (`workflow_dispatch`)

---

## Author

**Paul Adegoke**
AltSchool Africa – Cloud Engineering Track
Semester 3 Assessment – Terraform Infrastructure Deployment

---
