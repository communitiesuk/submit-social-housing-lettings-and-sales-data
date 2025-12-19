---
nav_order: 5
---

# Infrastructure

## Current infrastructure

Currently, there are four environments with infrastructure:

- Meta
- Development (Review Apps)
- Staging
- Production

### Meta

This holds the Terraform “backend” and the ECR(s).
The Terraform “backend” consists of:

- S3 buckets - for storing Terraform state files. One for all non-production environments (including the meta environment itself), and another just for production.
- DynamoDB - for managing access and locking of all state files.

The ECR(s) are:

- core - holds the application Docker images.
- db-migration - holds the Docker images curated to help migrate a DB from PaaS to AWS.
- s3-migration - holds the Docker images curated to help migrate S3 files from PaaS to AWS.
  N.B. the migration ECRs may or may not be present, depending on if the Terraform has been configured to create migration infrastructure. The migration infrastructure is only used to help migrate the DB and S3 from PaaS to AWS, so is usually therefore only temporarily present.

### Development / Staging / Production

These are the main environments holding the “application” infrastructure.
Though not exhaustive, each of them will generally contain the following key components:

- ECS Fargate cluster
- RDS (PostgreSQL database)
- ElastiCache (Redis data store)
- S3 buckets
  - One for Bulk upload (sometimes also to referred to as the CSV bucket)
  - One for CDS Export
- VPC
- Private subnets
- Public subnets
- Load Balancer
- Other misc. networking components (e.g. routing tables, gateways)
- CloudFront (Content Delivery Network)
- AWS Shield (DDoS protection, when enabled)
- WAF (Firewall)

### Development / Review Apps

The development environment is used for Review Apps, and has some infrastructure that is created per-review-app and some that is shared by all apps.
In general, each review app has its own ECS Fargate cluster and Redis instances (plus any infrastructure to enable this), while the rest is shared.

Where to find the Infrastructure?
The infrastructure is managed as code.
In the terraform folder of the codebase, there will be dedicated sub-folders for each of the aforementioned environments, where all the infrastructure for them is defined.

![Architecture Diagram](https://raw.githubusercontent.com/communitiesuk/submit-social-housing-lettings-and-sales-data/main/docs/images/architecture_diagram.png)
![Context Diagram](https://raw.githubusercontent.com/communitiesuk/submit-social-housing-lettings-and-sales-data/main/docs/images/context_diagram.png)
