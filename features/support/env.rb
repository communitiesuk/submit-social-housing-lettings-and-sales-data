require 'cucumber/rails'
require "capybara-screenshot/cucumber"
require "capybara/cuprite"

ActionController::Base.allow_rescue = false

begin
  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end


Cucumber::Rails::Database.javascript_strategy = :truncation

Capybara.register_driver :cuprite do |app|
  Capybara::Cuprite::Driver.new(app, headless:        true,
                                     js_errors:       true,
                                     window_size:     [1600, 1200],
                                     timeout:         30,
                                     process_timeout: 60)
end
Capybara.javascript_driver = :cuprite

Capybara::Screenshot.register_driver(:cuprite) do |driver, path|
  driver.render(path, full: true)
end

Cucumber::Rails::Database.javascript_strategy = :truncation

World(FactoryBot::Syntax::Methods)
