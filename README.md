# CNAPP – Security Scenarios Lab

This project provisions a small but diverse AWS environment designed to support cloud security posture, identity, workload, data, and Kubernetes security use cases.

⚠️ Important: This code intentionally creates insecure resources. Use only in a sandbox / test account.

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

* Review and customize `terraform.auto.tfvars` as needed
* Ensure a valid AWS region is configured
* Internet access is required for:

## 2. Resources Created

This Terraform project creates the following core AWS resources:

### Compute & Containers

* **1 EC2 instance**

  * With generated SSH key pair
  * Custom security group rules
  * Publicly accessible (intentional for security testing)
* **1 Amazon EKS cluster**

  * EKS control plane IAM role
  * Managed node group
* **1 Amazon ECR repository**

  * For container image storage

### Data & Storage

* **1 Amazon RDS instance**

  * MySQL 8.0
  * Publicly accessible (intentional for security testing)
* **1 Amazon S3 bucket**

  * Intended for database backups or artifacts
  * Publicly accessible (intentional for security testing)

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

### 1. CSPM – Cloud Security Posture Management

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

### 2. CIEM – Cloud Infrastructure Entitlement Management

**Scenario:**

* IAM roles with broad permissions
* IAM role that can be used for privilege escalation
* Policy attachments that exceed least-privilege principles

**What it tests:**

* Excessive permissions
* Privilege escalation paths
* Unused or risky IAM roles

---

### 3. KSPM – Kubernetes Security Posture Management

**Scenario:**

* EKS cluster with default configurations
* Node IAM role permissions exposed to workloads
* Potential lack of pod security standards

**What it tests:**

* Kubernetes CIS benchmarks
* Cluster hardening gaps
* IAM-to-pod access risks

---

### 4. DSPM – Data Security Posture Management

**Scenario:**

* MySQL RDS storing application data
* Publically accessable S3 bucket used for database backups
* No explicit encryption or data classification controls
* S3 bucket with sensitive data

**What it tests:**

* Sensitive data exposure
* Encryption at rest validation
* Data residency and access paths
