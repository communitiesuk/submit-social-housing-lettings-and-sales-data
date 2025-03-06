---
nav_order: 3
---

# Local development

The most common way to run a development version of the application is run with local dependencies.

Dependencies:

- [Ruby](https://www.ruby-lang.org/en/)
- [Rails](https://rubyonrails.org/)
- [PostgreSQL](https://www.postgresql.org/)
- [NodeJS](https://nodejs.org/en/)
- [Gecko driver](https://github.com/mozilla/geckodriver/releases) (for running Selenium tests)

We recommend using [RBenv](https://github.com/rbenv/rbenv) to manage Ruby versions.

We recommend using [nvm](https://github.com/nvm-sh/nvm) to manage NodeJS versions.

## Pre-setup installation

1. Install PostgreSQL

   macOS:

   ```bash
   brew install postgresql
   brew services start postgresql
   ```

   Linux (Debian):

   ```bash
   sudo apt install -y postgresql postgresql-contrib libpq-dev
   sudo systemctl start postgresql
   ```

2. Create a Postgres user

   ```bash
   sudo su - postgres -c "createuser <username> -s -P"
   ```

3. Install RBenv and Ruby-build

   macOS:

   ```bash
   brew install rbenv
   rbenv init
   mkdir -p ~/.rbenv/plugins
   git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
   ```

   Linux (Debian):

   ```bash
   sudo apt install -y rbenv git
   rbenv init
   echo 'eval "$(rbenv init -)"' >> ~/.bashrc
   mkdir -p ~/.rbenv/plugins
   git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
   ```

4. Install Ruby and Bundler

   ```bash
   rbenv install 3.1.6
   rbenv global 3.1.6
   source ~/.bashrc
   gem install bundler
   ```

5. Install JavaScript dependencies

   Note that we currently use node v16, which is no longer the latest LTS version so you will need to specify the version number when installing

   macOS (using nvm):

   ```bash
   nvm install 20
   nvm use 20
   brew install yarn
   ```

   or you could run it without specifying the version and it should use the version from .nvmrc

   ```bash
   nvm install
   nvm use
   brew install yarn
   ```

   Linux (Debian):

   ```bash
   curl -sL https://deb.nodesource.com/setup_20.x | sudo bash -
   sudo apt -y install nodejs
   mkdir -p ~/.npm-packages
   npm config set prefix ~/.npm-packages
   echo 'NPM_PACKAGES="~/.npm-packages"' >> ~/.bashrc
   echo 'export PATH="$PATH:$NPM_PACKAGES/bin"' >> ~/.bashrc
   source ~/.bashrc
   npm install --location=global yarn
   ```

6. (For running tests) Install Gecko Driver

   Linux (Debian):

   ```bash
   wget https://github.com/mozilla/geckodriver/releases/download/v0.31.0/geckodriver-v0.31.0-linux64.tar.gz
   tar -xvzf geckodriver-v0.31.0-linux64.tar.gz
   rm geckodriver-v0.31.0-linux64.tar.gz
   chmod +x geckodriver
   sudo mv geckodriver /usr/local/bin/
   ```

Also ensure you have firefox installed

7. Clone the repo

   ```bash
   git clone https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data.git
   ```

## Application setup

1. Copy the `.env.example` to `.env` and replace the database credentials with your local postgres user credentials.

2. Install the dependencies:

   ```bash
   bundle install && yarn install
   ```

3. Create the database & run migrations:

   ```bash
   bundle exec rake db:create db:migrate
   ```

4. Seed the database if required:

   ```bash
   bundle exec rake db:seed
   ```

5. For Ordinance Survey related functionality, such as using the UPRN, you will need to set OS_DATA_KEY in your .env file. This key is shared across the team and can be found in AWS Secrets Manager.
6. For email functionality, you will need a GOV.UK Notify API key, which is individual to you. Ask an existing team member to invite you to the "CORE Helpdesk" Notify service. Once invited, sign in and go to "API integration" to generate an API key, and set this as `GOVUK_NOTIFY_API_KEY` in your .env file.

## Running Locally

### Application

Start the dev servers

a. Using Foreman:

```bash
./bin/dev
```

b. Individually:

Rails:

```bash
bundle exec rails s
```

JavaScript (for hot reloading):

```bash
yarn build --mode=development --watch
```

If you’re not modifying front end assets you can bundle them as a one off task:

```bash
yarn build --mode=development
```

Development mode will target the latest versions of Chrome, Firefox and Safari for transpilation while production mode will target older browsers.

The Rails server will start on <http://localhost:3000>.

To sign in locally, you can use any username and password from your local database. The seed task creates users in various roles all with the password `REVIEW_APP_USER_PASSWORD` from your .env file (which has default value `password`).
You can also create a user in the database manually with the details of your choice, but you will need to generate a correctly encrypted password. You can find the value to use for encrypted password which corresponds to the password `YOURPASSWORDHERE` using `User.new(:password => [YOURPASSWORDHERE]).encrypted_password`.

### Debugging

You can use `binding.pry` to pause the execution of the code at that line and open an interactive console.
More details on Pry are available at https://pry.github.io/ .

RubyMine also offers built-in debugger functionality.
Add a Rails run configuration for the project to RubyMine (the default setup should just work) and you can choose between running the project using the play icon to run it normally or using the bug icon to run with the debugger attached.
You can also run tests with the debugger attached from the spec files.
When running any code in RubyMine with the debugger attached, click the line numbers to place a breakpoint.
Right click a breakpoint for advanced options like setting conditions for the breakpoint to trigger.
When the breakpoint is hit, code execution pauses and you can evaluate expressions, step through the code, and see the values of variables in the current scope.
You can "watch" important expressions to see their values change as you step through the code.
More details on debugging in RubyMine can be found at https://www.jetbrains.com/help/ruby/debugging-code.html .

### Tests

```bash
bundle exec rspec
```

To run a specific folder use

```bash
bundle exec rspec ./spec/folder
```

To run individual files use

```bash
bundle exec rspec ./spec/path/to/file.rb
```

or run individual files/tests from your IDE

### Feature toggles

Feature toggles can be found in `app/services/feature_toggle.rb`

### Formatting

- `yarn prettier . --write` for scss, yml, md, and json files
- `yarn standard --fix` for js files
- `bundle exec rubocop -A` to autocorrect safe rubocop offenses in ruby files

### Linting

```bash
bundle exec rake lint
```

## Using Docker

1. Build the image:

   ```bash
   docker-compose build
   ```

2. Run the database migrations:

   ```bash
   docker-compose run --rm app /bin/bash -c 'rake db:migrate'
   ```

3. Seed the database if required:

   ```bash
   docker-compose run --rm app /bin/bash -c 'rake db:seed'
   ```

4. To be able to debug with Pry run the app using:

   ```bash
   docker-compose run --service-ports app
   ```

If this is not needed you can run `docker-compose up` as normal

The Rails server will start on <http://localhost:8080>.

5. To run the test suite in docker:

   ```bash
   docker-compose run --rm app /bin/bash -c ' RAILS_ENV=test rspec'
   ```
