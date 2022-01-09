# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem "rails", "~> 7.0.2"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use Puma as the app server
gem "puma", "~> 5.0"
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"
# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"
# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"
# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.4", require: false
# GOV UK frontend components
gem "govuk-components"
# GOV UK component form builder DSL
gem "govuk_design_system_formbuilder"
# GOV UK Notify
gem "notifications-ruby-client"
# Turbo and Stimulus
gem "hotwire-rails"
# Administration framework
gem "activeadmin"
# Admin charts
gem "chartkick"
# Spreadsheet parsing
gem "roo"
# Json Schema
gem "json-schema"
# Authentication
# Point at branch until devise is compatible with Turbo, see https://github.com/heartcombo/devise/pull/5340
gem "devise", github: "baarkerlounger/devise", branch: "dluhc-fixes"
# Two-factor Authentication for devise models. Pointing at fork until this is merged for Rails 6 compatibility
# https://github.com/Houdini/two_factor_authentication/pull/204
gem "two_factor_authentication", github: "baarkerlounger/two_factor_authentication"
# UK postcode parsing and validation
gem "uk_postcode"
# Get rich data from postcode lookups. Wraps postcodes.io
gem "postcodes_io"
# Use Ruby objects to build reusable markup. A React inspired evolution of the presenter pattern
gem "view_component"
# Use the AWS S3 SDK as storage mechanism
gem "aws-sdk-s3"
# Track changes to models for auditing or versioning.
gem "paper_trail"
# Store active record objects in version whodunnits
gem "paper_trail-globalid"
# Request rate limiting
gem "rack-attack"
gem "redis"
# Receive exceptions and configure alerts
gem "sentry-rails"
gem "sentry-ruby"

group :development, :test do
  # Check gems for known vulnerabilities
  gem "bundler-audit"
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "pry-byebug"
end

group :development do
  gem "listen", "~> 3.3"
  gem "overcommit", ">= 0.37.0"
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 4.1.0"
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem "rack-mini-profiler", "~> 2.0"
  gem "rubocop-govuk", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "scss_lint-govuk"
end

group :test do
  gem "capybara", require: false
  gem "capybara-lockstep"
  gem "factory_bot_rails"
  gem "rspec-rails", require: false
  gem "selenium-webdriver", require: false
  gem "simplecov", require: false
  gem "timecop", "~> 0.9.4"
  gem "webmock", require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
