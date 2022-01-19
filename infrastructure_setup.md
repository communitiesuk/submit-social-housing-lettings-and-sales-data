# Staging

1. Login:\
`cf login -a api.london.cloud.service.gov.uk -u <your_username>`

2. Set your deployment target (staging):\
`cf target -o dluhc-core -s staging`

3. Create required backing services (this will take ~15 mins to finish creating):
`cf create-service postgres tiny-unencrypted-13 dluhc-core-staging-postgres`

4. Deploy manifest:
`cf push dluhc-core-staging --strategy rolling`
