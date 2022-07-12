# Submit social housing lettings and sales data (CORE)

[![Production CI/CD Pipeline](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data/actions/workflows/production_pipeline.yml/badge.svg)](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data/actions/workflows/production_pipeline.yml)
[![Staging CI/CD Pipeline](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data/actions/workflows/staging_pipeline.yml/badge.svg)](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data/actions/workflows/staging_pipeline.yml)

Ruby on Rails app that handles the submission of lettings and sales of social housing data in England. Currently in private beta.

## Domain documentation

* [Domain and technical documentation](https://communitiesuk.github.io/submit-social-housing-lettings-and-sales-data)
  * [Local development setup](https://communitiesuk.github.io/submit-social-housing-lettings-and-sales-data/setup)
  * [Architecture decision records](https://communitiesuk.github.io/submit-social-housing-lettings-and-sales-data/adr)
* [API browser](https://communitiesuk.github.io/submit-social-housing-lettings-and-sales-data/api) (using this [OpenAPI specification](docs/api/v1.json))
* [Design history](https://core-design-history.herokuapp.com)

### Running documentation locally

The documentation website can be generated and served locally using Jekyll.

1. Change into the `/docs/` directory:\
`cd docs`

2. Install Jekyll and its dependencies:\
`bundle install`

3. Start the Jekyll server:\
`bundle exec jekyll serve`

4. View the website:\
<http://localhost:4000>

## System architecture

![View of system architecture](docs/images/architecture.drawio.png)

## User interface

![View of the logs list](docs/images/service.png)
