# CNAPP – Security Scenarios Lab

This project provisions a small but diverse AWS environment designed to support cloud security posture, identity, workload, data, and Kubernetes security use cases.

⚠️ Important: This code intentionally creates insecure resources. Use only in a sandbox / test account.

1. [Requirements](#1-requirements)
2. [Resources Created](#2-resources-created)
3. [Security Scenarios Covered](#3-security-scenarios-covered)
  - [CSPM](#1-cspm--cloud-security-posture-management)
  - [CIEM](#2-ciem--cloud-infrastructure-entitlement-management)
  - [KSPM](#3-kspm--kubernetes-security-posture-management)
  - [DSPM](#4-dspm--data-security-posture-management)
4. [Getting Started](#4-getting-started)
5. [Cleanup](#5-cleanup)

## 1. Requirements

To successfully deploy this Terraform project, the following requirements must be met:

### Tooling

* **Terraform**
* **AWS CLI**
* **kubectl** (for interacting with the EKS cluster)
* **Docker** (for building/pushing images to ECR, if applicable)

### AWS Account & Access

* An active **AWS account**
* AWS credentials configured locally via one of the following:

  * `~/.aws/credentials`
  * Environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
  * IAM role (if running in AWS)
* Permissions to create and manage:

  * EC2, EKS, ECR
  * RDS
  * S3
  * IAM roles and policies
  * VPC and security groups
  * Key pairs

### Terraform Configuration

* Review and customize `terraform.tfvars` as needed
* Ensure a valid AWS region is configured

## 2. Resources Created

This Terraform project creates the following core AWS resources:

### Compute & Containers

* **1 EC2 instance**

  * With generated SSH key pair
  * Custom security group rules
  * Publicly accessible (intentional for security testing)
* **1 Amazon EKS cluster**

  * EKS control plane IAM role
  * Managed node group with 2 nodes
* **1 Amazon ECR repository**

  * For container image storage

### Data & Storage

* **1 Amazon RDS instance**

  * MySQL 8.0
  * Publicly accessible (intentional for security testing)
* **1 Amazon S3 bucket**

  * Intended for database backups or artifacts
  * Publicly accessible (intentional for security testing)
* **1 Amazon S3 bucket**

  * Intended for database sensitive data

### Identity & Access Management

* Multiple **IAM roles**, including:

  * EC2 instance role
  * EKS cluster role
  * EKS node group role
* IAM policy attachments for:

  * EKS
  * EC2
  * Container networking

### Networking & Security

* **Security groups** with:

  * SSH (22) access
  * Database access
  * Kubernetes-related traffic
* TLS private key generation for SSH access

## 3. Security Scenarios Covered

This environment intentionally enables **multiple cloud security domains** and is well suited for security tooling validation, demos, and detections.

### 3.1. CSPM – Cloud Security Posture Management

**Scenario:**

* Publicly accessible RDS instance
* Publically accessable EC2 instance
* Overly permissive security group ingress rules
* S3 bucket without restrictive bucket policies

**What it tests:**

* Detection of misconfigurations
* Public exposure risks
* Non-compliant cloud resources

---

### 3.2. CIEM – Cloud Infrastructure Entitlement Management

**Scenario:**

* IAM roles with broad permissions
* IAM role that can be used for privilege escalation
* Policy attachments that exceed least-privilege principles

**What it tests:**

* Excessive permissions
* Privilege escalation paths
* Unused or risky IAM roles

---

### 3.3. KSPM – Kubernetes Security Posture Management

**Scenario:**

* EKS cluster with default configurations
* Node IAM role permissions exposed to workloads
* Potential lack of pod security standards

**What it tests:**

* Kubernetes CIS benchmarks
* Cluster hardening gaps
* IAM-to-pod access risks

---

### 3.4. DSPM – Data Security Posture Management

**Scenario:**

* MySQL RDS storing application data
* Publically accessable S3 bucket used for database backups
* No explicit encryption or data classification controls
* S3 bucket with sensitive data

**What it tests:**

* Sensitive data exposure
* Encryption at rest validation
* Data residency and access paths

## 4. Getting Started

On your machine, run the following commands.
```
git clone https://github.com/bmppa/cnapp-pov-test.git
cd cnapp-pov-test
```

For testing on AWS:
```
cd aws
terraform init
terraform apply
```

Once Terraform finishes running you can retrieve the SSH private key using the following command.

```
terraform output -raw private_key > myKey.pem && chmod 400 myKey.pem && ssh-add myKey.pem
```

To connect to the MongoDB instance you can simply do `ssh ubuntu@<PUBLIC_IP_ADDRESS>`

## 5. Cleanup

Once you are done with the testing, you can delete all the resources by running the command:
```
terraform destroy
```