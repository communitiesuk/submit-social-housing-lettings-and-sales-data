# Testing strategy

- We use [RSpec](https://rspec.info/) and [Capybara](https://teamcapybara.github.io/capybara/)

- Capybara is used for our feature tests. These use the Rack driver by default (faster) or the Gecko driver (installation required) when the `js: true` option is passed for a test.

- Capybara is configured to run in headless mode but this can be toggled by commenting out `app/spec/rails_helper.rb#L14`

- Capybara is configured to use Gecko driver for JavaScript tests as Chrome is more commonly used and so naturally more likely to be better tested but this can be switched to Chrome driver by changing `app/spec/rails_helper.rb#L13`

- Feature specs are generally written sparingly as they’re also the slowest, where possible a request spec is preferred as this still tests a large surface area (route, controller, model, view) without the performance impact. They are not suitable for tests that need to run JavaScript or test that a specific set of interaction events that trigger a specific set of requests (with high confidence).

- Test data is created with [FactoryBot](https://github.com/thoughtbot/factory_bot) where ever possible
