## Dependencies

Pre-requisites:

- Ruby 3.1
- Rails 7
- Postgres 13
- Node 16

### Quick start

1. Copy the `.env.example` to `.env` and replace the database credentials with your local postgres user credentials.

2. Install the dependencies:\
  `bundle install`

3. Create the database:\
  `rake db:create`

4. Run the database migrations:\
  `rake db:migrate`

5. Seed the database if required:\
`rake db:seed`

6. Seed the database with rent ranges if required (~7000 rows per year):\
`rake "data_import:rent_ranges[<start_year>,<rent_ranges_path>]"`

    For 2021-2022 ranges run:\
    `rake "data_import:rent_ranges[2021,config/rent_range_data/2021.csv]"`

7. Install the frontend depenencies:\
  `yarn install`

8. Start the dev servers using foreman:\
  `./bin/dev`

  Or start them individually:\

  a. Rails:\
    `bundle exec rails s`

  b. JS (for hot reloading):\
    `yarn build --mode=development --watch`

If you're not modifying front end assets you can bundle them as a one off task:\
  `yarn build --mode=development`

Development mode will target the latest versions of Chrome, Firefox and Safari for transpilation while production mode will target older browsers.

The Rails server will start on <http://localhost:3000>.

Running the test suite (front end assets need to be built or server needs to be running):\
  `bundle exec rspec`

### Using Docker

1. Build the image:\
`docker-compose build`

2. Run the database migrations:\
`docker-compose run --rm app /bin/bash -c 'rake db:migrate'`

3. Seed the database if required:\
`docker-compose run --rm app /bin/bash -c 'rake db:seed'`

4. To be able to debug with Pry run the app using:\
`docker-compose run --service-ports app`

If this is not needed you can run `docker-compose up` as normal

The Rails server will start on <http://localhost:8080>.
