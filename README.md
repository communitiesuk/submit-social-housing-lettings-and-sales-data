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

The cloud infrastructure running this application is set up using the [infrastructure repository](https://github.com/communitiesuk/mhclg-data-collection-beta-infrastructure)
