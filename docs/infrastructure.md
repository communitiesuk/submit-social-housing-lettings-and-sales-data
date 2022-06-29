# Infrastructure

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

    This will use the [manifest file](staging_manifest.yml)

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

3. Create required Postgres and S3 bucket backing services (this will take ~15 mins to finish creating):

    ```bash
    cf create-service postgres tiny-unencrypted-13 dluhc-core-staging-postgres
    cf create-service aws-s3-bucket default dluhc-core-staging-import-bucket
    cf create-service aws-s3-bucket default dluhc-core-staging-export-bucket
    ```

4. Deploy manifest:

    ```bash
    cf push dluhc-core-staging --strategy rolling
    ```

5. Bind S3 services to app:

    ```bash
    cf bind-service dluhc-core-staging dluhc-core-staging-import-bucket -c '{"permissions": "read-only"}'
    cf bind-service dluhc-core-staging dluhc-core-staging-export-bucket -c '{"permissions": "read-write"}'
    ```

6. Create a service keys for accessing the S3 bucket from outside Gov PaaS:

    ```bash
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

3. Create required Postgres and S3 bucket backing services (this will take ~15 mins to finish creating):

    ```bash
    cf create-service postgres small-ha-13 dluhc-core-production-postgres
    cf create-service aws-s3-bucket default dluhc-core-production-import-bucket
    cf create-service aws-s3-bucket default dluhc-core-production-export-bucket
    ```

4. Deploy manifest:

    ```bash
    cf push dluhc-core-production --strategy rolling
    ```

5. Bind S3 services to app:

    ```bash
    cf bind-service dluhc-core-production dluhc-core-production-import-bucket -c '{"permissions": "read-only"}'
    cf bind-service dluhc-core-production dluhc-core-production-export-bucket -c '{"permissions": "read-write"}'
    ```

6. Create a service keys for accessing the S3 bucket from outside Gov PaaS:

    ```bash
    cf create-service-key dluhc-core-production-import-bucket data-import -c '{"allow_external_access": true}'
    cf create-service-key dluhc-core-production-export-bucket data-export -c '{"allow_external_access": true, "permissions": "read-only"}'
    ```
