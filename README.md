[![CI/CD Pipeline](https://github.com/communitiesuk/mhclg-data-collection-beta/actions/workflows/pipeline.yml/badge.svg?branch=main&event=push)](https://github.com/communitiesuk/mhclg-data-collection-beta/actions/workflows/pipeline.yml)

# Data Collection App

This is the codebase for the Ruby on Rails app that will handle the submission of Lettings and Sales of Social Housing in England data.


## API documentation

API documentation can be found here: https://communitiesuk.github.io/mhclg-data-collection-beta/. This is driven by [OpenAPI docs](docs/api/DLUHC-CORE-Data.v1.json)


## Required Setup

Pre-requisites:

- Ruby
- Rails
- Postgres

### Quick start

1. Copy the `.env.example` to `.env` and replace the database credentials with your local postgres user credentials.

2. Install the dependencies:\
  `bundle install`

3. Create the database:\
  `rake db:create`

4. Run the database migrations:\
  `rake db:migrate`

5. Install the frontend depenencies:\
  `yarn install`

6. Start the Rails server:\
  `bundle exec rails s`

The Rails server will start on <http://localhost:3000>.

### Using Docker

```sh
docker-compose build
docker-compose run --rm app rails db:create
docker-compose up
```

The Rails server will start on <http://localhost:8080>.

Note `docker-compose` runs the production docker image (`RAILS_ENV=production`) as the Dockerfile doesn’t include development gems to keep the image size down.

## Infrastructure

This application is running on [GOV.UK PaaS](https://www.cloud.service.gov.uk/). To deploy you need to:

1. Contact your organisation manager to get an account in `dluhc-core` organization and in the relevant spaces (sandbox/production).

2. [Install the Cloud Foundry CLI](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html)

3. Login:\
`cf login -a api.london.cloud.service.gov.uk -u <your_username>`

4. Set your deployment target (sandbox/production):\
`cf target -o dluhc-core -s <deploy_environment>`

5. Deploy:\
`cf push dluhc-core --strategy rolling`. This will use the [manifest file](manifest.yml)

Once the app is deployed:

1. Get a Rails console:\
`cf ssh dluhc-core -t -c "/tmp/lifecycle/launcher /home/vcap/app 'rails console' ''"`

2. Check logs:\
`cf logs dluhc-core --recent`

#### Troubleshooting deployments

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

## Single log submission

The form for this is driven by a JSON file in `/config/forms/{start_year}_{end_year}.json`

The JSON should follow the structure:

```jsonc
{
  "form_type": "lettings" / "sales",
  "start_year": Integer, // i.e. 2020
  "end_year": Integer, // i.e. 2021
  "sections": {
    "[snake_case_section_name_string]": {
      "label": String,
      "subsections": {
        "[snake_case_subsection_name_string]": {
          "label": String,
          "pages": {
            "[snake_case_page_name_string]": {
              "header": String,
              "description": String,
              "questions": {
                "[snake_case_question_name_string]": {
                  "header": String,
                  "hint_text": String,
                  "check_answer_label": String,
                  "type": "text" / "numeric" / "radio" / "checkbox" / "date",
                  "min": Integer, // numeric only
                  "max": Integer, // numeric only
                  "step": Integer, // numeric only
                  "answer_options": { // checkbox and radio only
                    "0": String,
                    "1": String
                  },
                  "conditional_for": {
                    "[snake_case_question_to_enable_1_name_string]": ["condition-that-enables"],
                    "[snake_case_question_to_enable_2_name_string]": ["condition-that-enables"]
                  }
                }
              },
              "conditional_route_to": {
                "[page_name_to_route_to]": {"question_name": "expected_answer"},
                "[page_name_to_route_to]": {"question_name": "expected_answer"}
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
- The ActiveRecord case log model has a field for each question name (must match). In the case of checkbox questions it must have one field for every answer option (again names must match).
- Text not required by a page/question such as a header or hint text should be passed as an empty string
- For conditionally shown questions conditions that have been implemented and can be used are:
  - Radio question answer option selected matches one of conditional e.g. ["answer-options-1-string", "answer-option-3-string"]
  - Numeric question value matches condition e.g. [">2"], ["<7"] or ["== 6"]

## JSON Form Validation against Schema

To validate the form JSON against the schema you can run:
`rake form_definition:validate["config/forms/2021_2022.json"]`

n.b. You may have to escape square brackets in zsh 
`rake form_definition:validate\["config/forms/2021_2022.json"\]`

This will validate the given form definition against the schema in `config/forms/schema/generic.json`.

You can also run:
`rake form_definition:validate_all`
This will validate all forms in directories = ["config/forms", "spec/fixtures/forms"]

## Useful documentation (external dependencies)

### GOV.UK Design System Form Builder for Rails

- [Examples](https://govuk-form-builder.netlify.app/)
- [Technical docs](https://www.rubydoc.info/gems/govuk_design_system_formbuilder/)
- [GitHub repository](https://github.com/DFE-Digital/govuk-formbuilder)

### GOV.UK Frontend

- [GitHub repository](https://github.com/alphagov/govuk-frontend)

### Hotwire (Turbo/Stimulus)

- [Docs](https://turbo.hotwired.dev/)
