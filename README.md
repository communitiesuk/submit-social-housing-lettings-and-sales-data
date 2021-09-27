# Data Collection App
This is the codebase for the Ruby/Rails app that will handle the submission of Lettings and Sales of Social Housing in England data.

## Required Setup

Pre-requisites

- Ruby
- Rails
- Postgres


### Setup Quickstart

Copy the `.env.example` to `.env` and replace the database credentials with your local postgres user credentials.

Create the database
`rake db:create`

Start the rails server
```
rails s
```
This starts the rails server on localhost:3000

or using Docker

```
docker-compose build
docker-compose run --rm app rails db:create
docker-compose up
```

This exposes the rails server on localhost:8080.

Note docker-compose runs the production docker image (RAILS_ENV=production) as the Dockerfile doesn't include development gems to keep the image size down.


### Infrastructure

This application is running on [Gov PaaS](https://www.cloud.service.gov.uk/). To deploy you need to:

- Contact your organisation manager to get an account in `dluhc-core` organization and in the relevant spaces (sandbox/production).
- Install the cloudfoundry cli https://docs.cloudfoundry.org/cf-cli/install-go-cli.html

- Login <br/>
`cf login -a api.london.cloud.service.gov.uk -u <your_username>`

- Set your deployment target (sandbox/production) <br/>
`cf target -o dluhc-core -s <deploy_environment>`

- Deploy <br/>
`cf push dluhc-core --strategy rolling`. This will use the [manifest file](manifest.yml)

- Get a rails console <br/>
`cf ssh dluhc-core -t -c "/tmp/lifecycle/launcher /home/vcap/app 'rails console' ''"`


### Single log submission

The form for this is driven by a json file in `/config/forms/{start_year}_{end_year}.json`

The JSON should follow the structure:

```
{
  form_type: [lettings/sales]
  start_year: yyyy
  end_year: yyyy
  sections: {
    snake case section name string: {
      label: string,
      subsections: {
        snake case subsection name string: {
          label: string,
          pages: {
            snake case page name string: {
              header: string,
              description: string,
              questions: {
                snake case question name string: {
                  header: string,
                  hint_text: string,
                  type: [text / numeric / radio / checkbox / date ],
                  min: integer, (numeric only),
                  max: integer, (numeric only),
                  step: integer (numeric only),
                  answer_options: { (checkbox and radio only)
                    "0": string,
                    "1": string
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
```

Assumptions made by the format:

- All forms have at least 1 section
- All sections have at least 1 subsection
- All subsections have at least 1 page
- All pages have at least 1 question
- The ActiveRecord case log model has a field for each question name (must match)
- Text not required by a page/question such as a header or hint text should be passed as an empty string
