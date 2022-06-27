# Testing strategy

- We use [RSpec](https://rspec.info/) and [Capybara](https://teamcapybara.github.io/capybara/)
- Capybara is used for our feature tests. These use the Rack driver by default (faster) or the Gecko driver (installation required) when the `js: true` option is passed for a test.
- Capybara is configured to run in headless mode but this can be toggled by commenting out `app/spec/rails_helper.rb#L14`
- Capybara is configured to use Gecko driver for JS tests as Chrome is more commonly used and so naturally more likely to be better tested but this can be switched to Chrome driver by changing `app/spec/rails_helper.rb#L13`
