# Staging

1. Login:\
`cf login -a api.london.cloud.service.gov.uk -u <your_username>`

2. Set your deployment target (staging):\
`cf target -o dluhc-core -s staging`

3. Create required Postgres and S3 bucket backing services (this will take ~15 mins to finish creating):\
  `cf create-service postgres tiny-unencrypted-13 dluhc-core-staging-postgres`

  `cf create-service aws-s3-bucket default dluhc-core-staging-import-bucket`

  `cf create-service aws-s3-bucket default dluhc-core-staging-export-bucket`

  `cf bind-service dluhc-core-staging dluhc-core-staging-import-bucket -c '{"permissions": "read-only"}'`

  `cf bind-service dluhc-core-staging dluhc-core-staging-export-bucket -c '{"permissions": "read-write"}'`

4. Deploy manifest:\
`cf push dluhc-core-staging --strategy rolling`
