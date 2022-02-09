# Staging

1. Login:\
  `cf login -a api.london.cloud.service.gov.uk -u <your_username>`

2. Set your deployment target (staging):\
  `cf target -o dluhc-core -s staging`

3. Create required Postgres and S3 bucket backing services (this will take ~15 mins to finish creating):\
  `cf create-service postgres tiny-unencrypted-13 dluhc-core-staging-postgres`

  `cf create-service aws-s3-bucket default dluhc-core-staging-import-bucket`

  `cf create-service aws-s3-bucket default dluhc-core-staging-export-bucket`

4. Deploy manifest:\
  `cf push dluhc-core-staging --strategy rolling`

5. Bind S3 services to app:\
  `cf bind-service dluhc-core-staging dluhc-core-staging-import-bucket -c '{"permissions": "read-only"}'`

  `cf bind-service dluhc-core-staging dluhc-core-staging-export-bucket -c '{"permissions": "read-write"}'`

6. Create a service keys for accessing the S3 bucket from outside Gov PaaS:\
  `cf create-service-key dluhc-core-staging-import-bucket data-import -c '{"allow_external_access": true}'`

  `cf create-service-key dluhc-core-staging-export-bucket data-export -c '{"allow_external_access": true, "permissions": "read-only"}'`


# Production

1. Login:\
  `cf login -a api.london.cloud.service.gov.uk -u <your_username>`

2. Set your deployment target (production):\
  `cf target -o dluhc-core -s production`

3. Create required Postgres and S3 bucket backing services (this will take ~15 mins to finish creating):\
  `cf create-service postgres small-ha-13 dluhc-core-production-postgres`

  `cf create-service aws-s3-bucket default dluhc-core-production-import-bucket`

  `cf create-service aws-s3-bucket default dluhc-core-production-export-bucket`

4. Deploy manifest:\
  `cf push dluhc-core-production --strategy rolling`

5. Bind S3 services to app:\
  `cf bind-service dluhc-core-production dluhc-core-production-import-bucket -c '{"permissions": "read-only"}'`

  `cf bind-service dluhc-core-production dluhc-core-production-export-bucket -c '{"permissions": "read-write"}'`

6. Create a service keys for accessing the S3 bucket from outside Gov PaaS:\
  `cf create-service-key dluhc-core-production-import-bucket data-import -c '{"allow_external_access": true}'`

  `cf create-service-key dluhc-core-production-export-bucket data-export -c '{"allow_external_access": true, "permissions": "read-only"}'`
