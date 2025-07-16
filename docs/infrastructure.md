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

## Production Deployment

The application is set up so that it can be deployed via GitHub actions. We use Git tags to mark releases. The only pre-requisite is that your GitHub account is added to our team.

To deploy you need to:

1. Determine [previous version](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data/tags), such as `v0.1.1`.
2. Create a [new release](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data/releases/new) with subsequent version (e.g., `v0.1.2`). On this page, create a new tag with that version and generate release notes. Save as draft.
3. Post release notes on Slack.
4. Ensure that there are no other pipelines running on the repo right now. If a staging deployment is running, it must complete before you can deploy to production.
5. Publish release. This will trigger the deployment pipeline.
6. Monitor alerting, logging and Sentry.
7. Post success message on Slack.
8. Tag tickets as ‘Released’ and move tickets to done on JIRA.

## Staging Deployment

When a commit is made to `main` the following GitHub action jobs are triggered:

1. **Test**: RSpec runs our test suite
2. **AWS Deploy**: If the Test stage passes, this job will deploy the app to AWS

When a pull request is opened to `main` only the Test stage runs.

## Review apps

When a pull request is opened a review app will be spun up. Each review app has its own ECS Fargate cluster and Redis instances (plus any infrastructure to enable this), while the rest is shared.

The review app github pipeline is independent of any test pipeline and therefore it will attempt to deploy regardless of the state the code is in.

The usual seeding process takes place when the review app boots so there will be some minimal data that can be used to login with. 2FA has been disabled in the review apps for easier access.

The app boots in a new environment called `development`. As such this is the environment you should filter by for sentry errors or to change any config.

After a sucessful deployment a comment will be added to the pull request with the URL to the review app for your convenience. When a pull request is updated e.g. more code is added it will re-deploy the new code.

Once a pull request has been closed the review app infrastructure will be tore down to save on any costs. Should you wish to re-open a closed pull request the review app will be spun up again.

### Review app deployment failures

One reason a review app deployment might fail is that it is attempting to run migrations which conflict with data in the database. For example you might have introduced a unique constraint, but the database associated with the review app has duplicate data in it that would violate this constraint, and so the migration cannot be run.

## Destroying/recreating infrastructure

Things to watch out for when destroying/creating infra:

- All resources
  - The lifecycle meta-argument prevent_destroy will stop you destroying things. Best to set this to false before trying to destroy!
- Database
  - skip_final_snapshot being false will prevent you from destroying the db without creating a final snapshot.
- Load Balancer
  - Sometimes when creating infra, you may see the error message: failure configuring LB attributes: InvalidConfigurationRequest: Access Denied for bucket: <load-balancer-access-log-bucket-name>. Please check S3bucket permission during a terraform apply. To get around this you may have wait a few minutes and try applying again to ensure everything is fully updated (the error shouldn’t appear on the second attempt). It’s unclear what the exact cause is, but as this is related to infra that enables load balancer access logging, it is suspected there might be a delay with the S3 bucket permissions being realised or the load balancer recognising it can access the bucket.
- S3
  - Terraform won’t let you delete buckets that have objects in them.
- Secrets
  - If you destroy secrets, they will actually be marked as ‘scheduled to delete’ which will take effect after a minimum of 7 days. You can’t recreate secrets with the same name during this period. If you want to destroy immediately, you need to do it from the command line (using your staging developer role, rather than your MHCLG-wide role used to apply Terraform) with this command: aws secretsmanager delete-secret --force-delete-without-recovery --secret-id <secret-arn>. (Note that if a secret is marked as scheduled to delete, you can undo this in the console to make it an ‘active’ secret again.)
  - You may need to manually re-enter secret values into Secrets Manager at some point. When you do, just paste the secret value as plain text (don’t enter a key name, or format it as JSON).
- ECS
  - Sometimes task definitions don’t get deleted. You may need to manually delete them.
  - After destroying the db, you’ll need to make sure the ad hoc ECS task which seeds the database gets run in order to set up the database correctly.
- SNS
  - When creating an email subscription in an environment, Terraform will look up the email to use as the subscription endpoint from Secrets Manager. If you haven’t already created this (e.g. by running terraform apply -target="module.monitoring" -var="create_secrets_first=true") then this will lead to the subscription creation erroring, because it can’t retrieve the value of the secret (because it doesn’t exist yet). If this happens, remember you’ll need to go to Secrets Manager in the console and enter the desired email (as plaintext, no quotation marks or anything else required) as the value of the secret (which is most likely called MONITORING_EMAIL). Then run another apply with Terraform and this time it should succeed.

![Architecture Diagram](https://raw.githubusercontent.com/communitiesuk/submit-social-housing-lettings-and-sales-data/main/docs/images/architecture_diagram.png)
![Context Diagram](https://raw.githubusercontent.com/communitiesuk/submit-social-housing-lettings-and-sales-data/main/docs/images/context_diagram.png)
