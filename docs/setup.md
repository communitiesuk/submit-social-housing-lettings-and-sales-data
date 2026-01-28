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

## Instructions for Windows users

If you are working on a windows machine, you will want to install the tools on [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) as some of them are not native to windows. The instructions in these docs assume a Debian-based distribution, such as Ubuntu.

_You will see a significant performance degradation if you are running the server on WSL whilst the files are on windows._ Thus, make sure to clone the repository into your WSL instance.

Some windows IDEs, such as [VSCode](https://code.visualstudio.com/docs/remote/wsl) and [RubyMine](jetbrains.com/help/ruby/remote-development-starting-page.html#run_in_wsl_ij) can connect you to WSL, which will allow you to develop as though the files were on the local windows filesystem. Ignore any reccommendations that you might see suggesting you keep the files on windows - our experience is that both tests and page loads are much slower when the files are on windows.

## Pre-setup installation

1. Install PostgreSQL

   If you already have a valid Postgres installation you can skip this step.

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

   If you already have a valid Postgres installation you can skip this step.

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

   Linux (Debian):

   ```bash
   npm install --global yarn
   ```

6. (For running tests) Install Gecko Driver

   Linux (Debian):

   Find the latest version at https://github.com/mozilla/geckodriver/releases/, right click the linux64.tar.gz download and copy URL.

   ```bash
   wget <url copied>
   tar -xvzf <file downloaded>
   rm <file downloaded>
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

5. Build assets once before running the app for the first time:

   ```bash
   yarn build --mode=development
   ```

6. For Ordinance Survey related functionality, such as using the UPRN, you will need to set `OS_DATA_KEY` in your .env file. This key is shared across the team and can be found in AWS Secrets Manager.
7. For email functionality, you will need a GOV.UK Notify API key, which is individual to you. Ask an existing team member to invite you to the "CORE Helpdesk" Notify service. Once invited, sign in and go to "API integration" to generate an API key, and set this as `GOVUK_NOTIFY_API_KEY` in your .env file.

## Running Locally

### Application

Start the dev servers via one of the following methods:

a. If using RubyMine, run the "submit-social-housing-lettings-and-sales-data" Rails configuration.

b. Using Foreman:

```bash
./bin/dev
```

c. Individually:

Rails:

```bash
bundle exec rails s
```

JavaScript (for hot reloading):

```bash
yarn build --mode=development --watch
```

Development mode will target the latest versions of Chrome, Firefox and Safari for transpilation while production mode will target older browsers.

The Rails server will start on <http://localhost:3000>.

To sign in locally, you can use any username and password from your local database. The seed task in `seeds.rb` creates users in various roles all with the password `REVIEW_APP_USER_PASSWORD` from your .env file (which has default value `password`).
To create any other users, you can log in as a support user and create new users via the admin interface. Or, you can edit the seed commands, or run similar commands in the rails console.
You can also insert a new user row using SQL, but you will need to generate a correctly encrypted password. You can find the value to use for encrypted password which corresponds to the password `YOURPASSWORDHERE` using `User.new(:password => [YOURPASSWORDHERE]).encrypted_password`.

### rbenv

In general, whenever needing to run a Ruby command, use `bundle exec <command>` to ensure the correct Ruby version and gemset are used. Rbenv will automatically use the correct Ruby version.

### Debugging

Add the line `binding.pry` to the code to pause the execution of the code at that line and open a powerful interactive console for debugging.
More details on Pry are available at <https://pry.github.io/> .

RubyMine also offers built-in debugging functionality, with the ability to manage breakpoints in the IDE.
To use this:

- To run the app with debugger: select the "core" Rails run configuration for the project in the top right, then click the bug icon to run with the debugger attached
- To run tests with debugger: use the arrows in the margin of spec files beside a section or an individual test
- To run anything else with debugger: go to `Run > Edit Configurations` and add the task you want to debug - options include Rails, Rake, Rspec, Ruby

Click a line number to place a breakpoint. Right click a breakpoint for advanced options on when to trigger and what to log. You can view all breakpoints, toggle them and configure them from the `View Breakpoints...` menu.

When the running code reaches a breakpoint, the debugger pauses execution and the debug panel can be used to:

- View the call stack and the values of variables in the current scope
- Evaluate and watch expressions
- Step through the code line by line
- Mute all breakpoints, resume, restart, etc

More details on debugging in RubyMine can be found at <https://www.jetbrains.com/help/ruby/debugging-code.html> .

### Tests

```bash
bundle exec rspec
```

Or if using RubyMine, right click a spec file and select the 'Run' option.

To run a specific folder use

```bash
bundle exec rspec ./spec/folder
```

To run individual files use

```bash
bundle exec rspec ./spec/path/to/file.rb
```

or run individual files/tests from your IDE

If you have made database changes, you may need to run the migrations for the test database:

```bash
bundle exec rake db:migrate RAILS_ENV=test
```

### Feature toggles

Feature toggles can be found in `app/services/feature_toggle.rb`

### Formatting

- `yarn prettier . --write` for scss, yml, md, and json files
- `yarn standard --fix` for js files
- `bundle exec rubocop -a` to autocorrect safe autocorrectable rubocop offenses in ruby files
- `bundle exec rubocop -A` to autocorrect all autocorrectable rubocop offenses in ruby files - both safe and unsafe

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
