# Data Collection App
This is the codebase for the Ruby/Rails app that will handle the submission of Lettings and Sales of Social Housing in England data.

## Required Setup

Pre-requisites

- Ruby
- Rails
- Postgres


### Setup Quickstart

From the data-collector directory

```
rake db:create
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
