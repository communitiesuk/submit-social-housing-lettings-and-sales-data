# Submit social housing lettings and sales data (CORE)

[![Production CI/CD Pipeline](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data/actions/workflows/production_pipeline.yml/badge.svg)](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data/actions/workflows/production_pipeline.yml)
[![Staging CI/CD Pipeline](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data/actions/workflows/staging_pipeline.yml/badge.svg)](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data/actions/workflows/staging_pipeline.yml)

Ruby on Rails app that handles the submission of lettings and sales of social housing data in England. Currently in private beta.

## Domain documentation

- [Service overview](docs/service_overview.md)
- [Organisations](docs/organisations.md)
- [Users and roles](docs/users.md)
- [Supported housing schemes](docs/schemes.md)

## Technical Documentation

- [Developer setup](docs/developer_setup.md)
- [Frontend](docs/frontend.md)
- [Testing strategy](docs/testing.md)
- [Form Builder](docs/form_builder.md)
- [Form Runner](docs/form_runner.md)
- [Infrastructure](docs/infrastructure.md)
- [Monitoring](docs/monitoring.md)
- [Exporting to CDS](docs/exports)
- [Application decision records](docs/adr)

## API documentation

API documentation can be found here: <https://communitiesuk.github.io/submit-social-housing-lettings-and-sales-data>. This is driven by [OpenAPI docs](docs/api/DLUHC-CORE-Data.v1.json)

## System architecture

![View of system architecture](docs/images/architecture.png)

## User interface

![View of the logs list](docs/images/service.png)
