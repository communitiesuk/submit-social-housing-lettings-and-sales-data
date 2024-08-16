---
nav_order: 4
---

# Testing

- We use [RSpec](https://rspec.info/) and [Capybara](https://teamcapybara.github.io/capybara/)

- Capybara is used for our feature tests. These use the Rack driver by default (faster) or the Gecko driver (installation required) when the `js: true` option is passed for a test.

- Capybara is configured to run in headless mode but this can be toggled by commenting out `app/spec/rails_helper.rb#L14`

- Capybara is configured to use Gecko driver for JavaScript tests as Chrome is more commonly used and so naturally more likely to be better tested but this can be switched to Chrome driver by changing `app/spec/rails_helper.rb#L13`

- Feature specs are generally written sparingly as they’re also the slowest, where possible a request spec is preferred as this still tests a large surface area (route, controller, model, view) without the performance impact. They are not suitable for tests that need to run JavaScript or test that a specific set of interaction events that trigger a specific set of requests (with high confidence).

- Test data is created with [FactoryBot](https://github.com/thoughtbot/factory_bot) where ever possible

## Parallel testing

- The RSpec test suite can be ran in parallel in local development for quicker turnaround times

- Setup with the following:

```sh
bundle exec rake parallel:setup
```

- Run with:

```sh
RAILS_ENV=test bundle exec rake parallel:spec
```

## Factories for Lettings Log, Sales Log, Organisation, and User

Each of these factories has nested relationships and callbacks that ensure associated objects are created and linked properly. For instance, creating a `lettings_log` involves creating or associating with a `user`, which in turn is linked to an `organisation`, potentially leading to creating `organisation_rent_periods` and a `data_protection_confirmation`.

This documentation outlines the objects that are created and/or persisted to the database when using FactoryBot to create or build models for LettingsLog, SalesLog, Organisation, and User. There are other factories, but they are simpler, less frequently used and don't have as much resource hierarchy.

### Lettings Log

Objects Created/Persisted:

- **User**: The `assigned_to` user is created.
  - **Organisation**: The `assigned_to` user’s organisation created by `User` factory.
- **DataProtectionConfirmation**: If `organisation` does not have DSA signed, `DataProtectionConfirmation` gets created with `assigned_to` user as a `data_protection_officer`
- **OrganisationRentPeriod**: If `log.period` is present and the `managing_organisation` does not have an `OrganisationRentPeriod` for that period, a new `OrganisationRentPeriod` is created and associated with `managing_organisation`.

Example Usage:

```
let(:lettings_log) { create(:lettings_log) }
```

### Sales Log

Objects Created/Persisted:

- **User**: The `assigned_to` user is created.
  - **Organisation**: The `assigned_to` user’s organisation created by `User` factory.
- **DataProtectionConfirmation**: If `organisation` does not have DSA signed, `DataProtectionConfirmation` gets created with `assigned_to` user as a `data_protection_officer`

Example Usage:

```
let(:sales_log) { create(:sales_log) }
```

### Organisation

Objects Created/Persisted:

- **OrganisationRentPeriod**: For each rent period in transient attribute `rent_periods`, an `OrganisationRentPeriod` is created.
- **DataProtectionConfirmation**: If `with_dsa` is `true` (default), a `DataProtectionConfirmation` is created with a `data_protection_officer`
- **User**: Data protection officer that signs the data protection confirmation

Example Usage:

```
let(:organisation) { create(:organisation, rent_periods: [1, 2])}
```

### User

Objects Created/Persisted:

- **Organisation**: User’s organisation.
- **DataProtectionConfirmation**: If `organisation` does not have DSA signed, `DataProtectionConfirmation` gets created with this user as a `data_protection_officer`

Example Usage:

```
let(:user) { create(:user) }
```
