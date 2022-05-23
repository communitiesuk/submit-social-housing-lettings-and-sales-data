require 'cucumber/rails'
require "capybara-screenshot/cucumber"

ActionController::Base.allow_rescue = false

begin
  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Cucumber::Rails::Database.javascript_strategy = :truncation

Capybara.javascript_driver = :headless

Capybara::Screenshot.register_driver(:headless) do |driver, path|
  driver.render(path, full: true)
end

Cucumber::Rails::Database.javascript_strategy = :truncation

World(FactoryBot::Syntax::Methods)
