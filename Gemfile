# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.4"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem "rails", "~> 7.0.8.5"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use Puma as the app server
gem "puma", "~> 5.6"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"
# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.4", require: false
# GOV UK frontend components
gem "govuk-components", "~> 5.1"
# GOV UK component form builder DSL
gem "govuk_design_system_formbuilder", "~> 5.0"
# Convert Markdown into GOV.UK frontend-styled HTML
gem "govuk_markdown"
gem "redcarpet", "~> 3.6"
# GOV UK Notify
gem "notifications-ruby-client"
# A modest javascript framework for the html you already have
gem "stimulus-rails"
# Spreadsheet parsing
gem "roo"
# Json Schema
gem "json-schema"
# Authentication
gem "devise"
# Two-factor Authentication for devise models.
gem "devise_two_factor_authentication"
# UK postcode parsing and validation
gem "uk_postcode"
# Get rich data from postcode lookups. Wraps postcodes.io
# Use Ruby objects to build reusable markup. A React inspired evolution of the presenter pattern
gem "view_component", "~> 3.9"
# Use the AWS S3 SDK as storage mechanism
gem "aws-sdk-s3"
# Track changes to models for auditing or versioning.
gem "paper_trail"
# Store active record objects in version whodunnits
gem "paper_trail-globalid"

gem "pundit"

# Request rate limiting
gem "rack", ">= 2.2.6.3"
gem "rack-attack"
gem "redis", "~> 4.8"
# Receive exceptions and configure alerts
gem "sentry-rails"
gem "sentry-ruby"
# Possessives in strings
gem "possessive"
# Strip whitespace from active record attributes
gem "auto_strip_attributes"
# Use sidekiq for background processing
gem "method_source", "~> 1.1"
gem "rails_admin", "~> 3.1"
gem "ruby-openai"
gem "sidekiq"
gem "sidekiq-cron"
gem "unread"

group :development, :test do
  # Check gems for known vulnerabilities
  gem "bundler-audit"
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-byebug"

  gem "parallel_tests"
end

group :development do
  gem "listen", "~> 3.3"
  gem "overcommit", ">= 0.37.0"
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 4.1.0"
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem "erb_lint", require: false
  gem "rack-mini-profiler", "~> 2.0"
  gem "rubocop-govuk", "4.3.0", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
end

group :test do
  gem "axe-core-rspec"
  gem "capybara", require: false
  gem "capybara-lockstep"
  gem "capybara-screenshot"
  gem "rspec-rails", require: false
  gem "selenium-webdriver", require: false
  gem "simplecov", require: false
  gem "timecop", "~> 0.9.4"
  gem "webmock", require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "cssbundling-rails"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

gem "excon", "~> 0.111.0"
