---
nav_order: 6
---

# Deployments

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
  - If you destroy secrets, they will actually be marked as ‘scheduled to delete’ which will take effect after a minimum of 7 days. You can’t recreate secrets with the same name during this period.
  - If you want to destroy immediately, you need to do it from the command line (using AWS CLI, see [here](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data-infrastructure/blob/main/docs/development_setup.md#set-up-aws-vault--cli)) with this command: aws secretsmanager delete-secret --force-delete-without-recovery --secret-id <secret-arn>. (Note that if a secret is marked as scheduled to delete, you can undo this in the console to make it an ‘active’ secret again.)
  - You may need to manually re-enter secret values into Secrets Manager at some point. When you do, just paste the secret value as plain text (don’t enter a key name, or format it as JSON).
- ECS
  - Sometimes task definitions don’t get deleted. You may need to manually delete them.
  - After destroying the db, you’ll need to make sure the ad hoc ECS task which seeds the database gets run in order to set up the database correctly.
