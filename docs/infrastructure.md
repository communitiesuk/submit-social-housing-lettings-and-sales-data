---
nav_order: 5
---

# Infrastructure

## Configuration

On [GOV.UK PaaS](https://www.cloud.service.gov.uk/), service credentials are appended to the environment variable `VCAP_SERVICES` when services [are bound](https://docs.cloud.service.gov.uk/deploying_services/s3/#bind-an-aws-s3-bucket-to-your-app) to an application.
Such services include datastores and S3 buckets.

Our application uses S3 and Redis clients and supports two different ways of parsing their configuration:
* Via the environment variable `VCAP_SERVICES` using the `PaasConfigurationService` class
* Via the environment variables `S3_CONFIG` and `REDIS_CONFIG` using the `EnvConfigurationService` class

`S3_CONFIG` and `REDIS_CONFIG` are populated using a similar structure than `VCAP_SERVICES`:

S3_CONFIG:
```json
[
  {
    "instance_name": "bucket_1",
    "credentials": {
      "aws_access_key_id": "123",
      "aws_secret_access_key": "456",
      "aws_region": "eu-west-1",
      "bucket_name": "my-bucket"
    }
  }
]
```

REDIS_CONFIG:
```json
[
  {
    "instance_name": "redis_1",
    "credentials": {
      "uri": "redis_uri"
    }
  }
]
```

In order to switch from using [GOV.UK PaaS](https://www.cloud.service.gov.uk/) provided services to external ones, instances of `PaasConfigurationService` need to be replaced by `EnvConfigurationService`.
This assumes that `S3_CONFIG` or/and `REDIS_CONFIG` are available.

Please check `full_import.rake` and `rack_attack.rb` for examples of how the configuration is used.

## Deployment

This application is running on [GOV.UK PaaS](https://www.cloud.service.gov.uk/). To deploy you need to:

1. Contact your organisation manager to get an account in `dluhc-core` organization and in the relevant spaces (staging/production).

2. [Install the Cloud Foundry CLI](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html)

3. Login:

    ```bash
    cf login -a api.london.cloud.service.gov.uk -u <your_username>
    ```

4. Set your deployment target (staging/production):

    ```bash
    cf target -o dluhc-core -s <deploy_environment>
    ```

5. Deploy:

    ```bash
    cf push dluhc-core --strategy rolling
    ```

    This will use the [manifest file](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data/blob/main/manifest.yml)

Once the app is deployed:

1. Get a Rails console:

    ```bash
    cf ssh dluhc-core-staging -t -c "/tmp/lifecycle/launcher /home/vcap/app 'rails console' ''"
    ```

2. Check logs:

    ```bash
    cf logs dluhc-core-staging --recent
    ```

### Troubleshooting deployments

A failed Github deployment action will occasionally leave a Cloud Foundry deployment in a broken state. As a result all subsequent Github deployment actions will also fail with the message `Cannot update this process while a deployment is in flight`.

```bash
cf cancel-deployment dluhc-core
```

You would then need to check the logs and fix the issue that caused the initial deployment to fail.

## CI/CD

When a commit is made to `main` the following GitHub action jobs are triggered:

1. **Test**: RSpec runs our test suite
2. **Deploy**: If the Test stage passes, this job will deploy the app to our GOV.UK PaaS account using the Cloud Foundry CLI

When a pull request is opened to `main` only the Test stage runs.

## Review apps

When a pull request is opened a review app will be spun up. The reviews apps connect to their own PostgreSQL and Redis instances with its own worker.

The review app github pipeline is independent of any test pipeline and therefore it will attempt to deploy regardless of the state the code is in.

The usual seeding process takes place when the review app boots so there will be some minimal data that can be used to login with. 2FA has been disabled in the review apps for easier access.

The app boots in a new environment called `review`. As such this is the environment you should filter by for sentry errors or to change any config.

After a sucessful deployment a comment will be added to the pull request with the URL to the review app for your convenience. When a pull request is updated e.g. more code is added it will re-deploy the new code.

Once a pull request has been closed the review app infrastructure will be tore down to save on any costs. Should you wish to re-open a closed pull request the review app will be spun up again.

### How to fix review app deployment failures 

One reason a review app deployment might fail is that it is attempting to run migrations which conflict with data in the database. For example you might have introduced a unique constraint, but the database associated with the review app has duplicate data in it that would violate this constraint, and so the migration cannot be run. There are two main ways to remedy this:

**Method 1 - Edit database via console**
1. Log in to Cloud Foundry
    ```bash
    cf login -a api.london.cloud.service.gov.uk -u <your_username>
    ```
    * Your username should be the email address you signed up to GOVUK PaaS with.
    * Choose the dev environment whilst logging in.
2. If you were already logged in then Cloud Foundry, then instead just target the dev environment
    ```bash
    cf target -o dluhc-core -s dev
    ```
3. Find the name of your app
    ```bash
    cf apps
    ```
    * The app name will be in this format: `dluhc-core-review-<pull-request-number>`.
4. Open a console for your app
    ```bash
    cf ssh <app-name-here> -t -c "/tmp/lifecycle/launcher /home/vcap/app 'rails console' ''"
    ```
5. Edit the database as appropriate, e.g. delete dodgy data and recreate correctly

**Method 2 - Nuke and restart**

1. Find the name of your app
    ```bash
    cf apps
    ```
    * The app name will be in this format: `dluhc-core-review-<pull-request-number>`.
2. Delete the app
    ```bash
    cf delete <app-name-here>
    ```
3. Find the name of the matching Postgres service
	```bash
    cf services
    ```
	* The service name will be in this format: `dluhc-core-review-<pull-request-number>-postgres`.
4. Delete the service
	```bash
    cf delete-service <service-name-here>
    ```
    * Use `cf services` or `cf service <service-name-here>` to check the operation status.
    * There's no need to delete the Redis service.
5. Re-run the whole review app pipeline in GitHub
    * If it fails it's likely that the deletion from the previous step hadn't completed yet. So just wait a few minutes and re-run the pipeline again.

## Setting up Infrastructure for a new environment

### Staging

1. Login:

    ```bash
    cf login -a api.london.cloud.service.gov.uk -u <your_username>
    ```

2. Set your deployment target (staging):

    ```bash
    cf target -o dluhc-core -s staging
    ```

3. Create required Postgres, Redis and S3 bucket backing services (this will take ~15 mins to finish creating):

    ```bash
    cf create-service postgres tiny-unencrypted-13 dluhc-core-staging-postgres
    cf create-service redis micro-6.x dluhc-core-staging-redis
    cf create-service aws-s3-bucket default dluhc-core-staging-csv-bucket
    cf create-service aws-s3-bucket default dluhc-core-staging-import-bucket
    cf create-service aws-s3-bucket default dluhc-core-staging-export-bucket
    ```

4. Deploy manifest:

    ```bash
    cf push dluhc-core-staging --strategy rolling
    ```

5. Bind S3 services to app:

    ```bash
    cf bind-service dluhc-core-staging dluhc-core-staging-csv-bucket
    cf bind-service dluhc-core-staging dluhc-core-staging-redis
    cf bind-service dluhc-core-staging dluhc-core-staging-import-bucket -c '{"permissions": "read-only"}'
    cf bind-service dluhc-core-staging dluhc-core-staging-export-bucket -c '{"permissions": "read-write"}'
    ```

6. Create a service keys for accessing the S3 bucket from outside Gov PaaS:

    ```bash
    cf create-service-key dluhc-core-staging-csv-bucket csv-bucket -c '{"allow_external_access": true}'
    cf create-service-key dluhc-core-staging-import-bucket data-import -c '{"allow_external_access": true}'
    cf create-service-key dluhc-core-staging-export-bucket data-export -c '{"allow_external_access": true, "permissions": "read-only"}'
    ```

### Production

1. Login:

    ```bash
    cf login -a api.london.cloud.service.gov.uk -u <your_username>
    ```

2. Set your deployment target (production):

    ```bash
    cf target -o dluhc-core -s production
    ```

3. Create required Postgres, Redis and S3 bucket backing services (this will take ~15 mins to finish creating):

    ```bash
    cf create-service postgres small-ha-13 dluhc-core-production-postgres
    cf create-service redis micro-ha-6.x dluhc-core-production-redis
    cf create-service aws-s3-bucket default dluhc-core-production-csv-bucket
    cf create-service aws-s3-bucket default dluhc-core-production-import-bucket
    cf create-service aws-s3-bucket default dluhc-core-production-export-bucket
    ```

4. Deploy manifest:

    ```bash
    cf push dluhc-core-production --strategy rolling
    ```

5. Bind S3 services to app:

    ```bash
    cf bind-service dluhc-core-production dluhc-core-production-csv-bucket
    cf bind-service dluhc-core-production dluhc-core-production-redis
    cf bind-service dluhc-core-production dluhc-core-production-import-bucket -c '{"permissions": "read-only"}'
    cf bind-service dluhc-core-production dluhc-core-production-export-bucket -c '{"permissions": "read-write"}'
    ```

6. Create a service keys for accessing the S3 bucket from outside Gov PaaS:

    ```bash
    cf create-service-key dluhc-core-production-csv-bucket dluhc-core-production-csv-bucket-service-key -c '{"allow_external_access": true}'
    cf create-service-key dluhc-core-production-import-bucket data-import -c '{"allow_external_access": true}'
    cf create-service-key dluhc-core-production-export-bucket data-export -c '{"allow_external_access": true, "permissions": "read-only"}'
    ```
