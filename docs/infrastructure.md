## Infrastructure

This application is running on [GOV.UK PaaS](https://www.cloud.service.gov.uk/). To deploy you need to:

1. Contact your organisation manager to get an account in `dluhc-core` organization and in the relevant spaces (staging/production).

2. [Install the Cloud Foundry CLI](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html)

3. Login:\
`cf login -a api.london.cloud.service.gov.uk -u <your_username>`

4. Set your deployment target (staging/production):\
`cf target -o dluhc-core -s <deploy_environment>`

5. Deploy:\
`cf push dluhc-core --strategy rolling`. This will use the [manifest file](staging_manifest.yml)

Once the app is deployed:

1. Get a Rails console:\
`cf ssh dluhc-core-staging -t -c "/tmp/lifecycle/launcher /home/vcap/app 'rails console' ''"`

2. Check logs:\
`cf logs dluhc-core-staging --recent`

### Troubleshooting deployments

A failed Github deployment action will occasionally leave a Cloud Foundry deployment in a broken state. As a result all subsequent Github deployment actions will also fail with the message `Cannot update this process while a deployment is in flight`.

`
cf cancel-deployment dluhc-core
`

You'd then need to check the logs and fix the issue that caused the initial deployment to fail.

## CI/CD

When a commit is made to `main` the following GitHub action jobs are triggered:

1. **Test**: RSpec runs our test suite
2. **Deploy**: If the Test stage passes, this job will deploy the app to our GOV.UK PaaS account using the Cloud Foundry CLI

When a pull request is opened to `main` only the Test stage runs.
