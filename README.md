# Submit social housing lettings and sales data (CORE)

[![Production CI/CD Pipeline](https://github.com/communitiesuk/mhclg-data-collection-beta/actions/workflows/production_pipeline.yml/badge.svg)](https://github.com/communitiesuk/mhclg-data-collection-beta/actions/workflows/production_pipeline.yml)
[![Staging CI/CD Pipeline](https://github.com/communitiesuk/mhclg-data-collection-beta/actions/workflows/staging_pipeline.yml/badge.svg)](https://github.com/communitiesuk/mhclg-data-collection-beta/actions/workflows/staging_pipeline.yml)

Ruby on Rails app that handles the submission of lettings and sales of social housing data in England. Currently in private beta.


## Technical Documentation

- [Developer setup](docs/developer_setup.md)
- [Form builder](docs/form_builder.md)
- [Form runner](docs/form_runner.md)
- [Infrastructure & CI/CD pipelines](docs/infrastructure.md)
- [Monitoring, logging & alerting](docs/monitoring.md)
- [Frontend](docs/frontend.md)
- [Testing strategies and style guide](docs/testing.md)
- [Export to CDS](docs/exports)

## API documentation

API documentation can be found here: <https://communitiesuk.github.io/mhclg-data-collection-beta>. This is driven by [OpenAPI docs](docs/api/DLUHC-CORE-Data.v1.json)


## Service

All lettings and and sales of social housing in England need to be logged with the Department for levelling up, housing and communities (DLUHC). This is done by Local Authorities and Housing Associations, who are the primary users of this service. Data is collected via a form that runs on an annual data collection window basis. Form changes are made annually to add new questions, remove any that are no longer needed, or adjust wording or answer options etc. Each data collection window runs from 1st April to 1st April + an extra 3 months to allow for any late submissions, meaning that between April and July, two collection windows are open simultaneously and logs can be submitted for either.

ADD (Analytics & Data Directorate) statisticians are the other primary users of the service. The data collected is transferred to DLUHCs data warehouse (CDS - consolidated data store), via nightly exports to XML which are transferred to S3 and ingested from there. CDS ingests and transforms the data, ultimately storing it in a MS SQL database and exposing it to analysts and statisticians via Amazon Workspaces.  

System architecture:
![View of system architecture](docs/images/architecture.png)

View of the service frontend:
![View of the logs list](docs/images/logs_list.png)
