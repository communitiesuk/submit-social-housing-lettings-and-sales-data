# Submit social housing lettings and sales data (CORE)

[![Production CI/CD Pipeline](https://github.com/communitiesuk/mhclg-data-collection-beta/actions/workflows/production_pipeline.yml/badge.svg)](https://github.com/communitiesuk/mhclg-data-collection-beta/actions/workflows/production_pipeline.yml)
[![Staging CI/CD Pipeline](https://github.com/communitiesuk/mhclg-data-collection-beta/actions/workflows/staging_pipeline.yml/badge.svg)](https://github.com/communitiesuk/mhclg-data-collection-beta/actions/workflows/staging_pipeline.yml)

Ruby on Rails app that handles the submission of lettings and sales of social housing data in England. Currently in private beta.

## Domain documentation

- [Service overview](docs/service_overview.md)
- [User roles](docs/user_roles.md)
- [Schemes](docs/schemes.md)
- [Organisation relationships (Parent/Child)](docs/organisation_relationships.md)

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


## System architecture
![View of system architecture](docs/images/architecture.png)

## UI:
![View of the logs list](docs/images/logs_list.png)
