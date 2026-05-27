# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

CORE — a Ruby on Rails app (the "Submit social housing lettings and sales data" service) that collects lettings and sales of social housing data in England for MHCLG. Data providers (Local Authorities and Private Registered Providers) submit logs; the data is exported nightly to CDS (Consolidated Data Store) via XML to S3.

Stack: Ruby 3.4.9, Rails 7.2, PostgreSQL, Sidekiq + Redis, Webpack/Propshaft, Stimulus, ViewComponent, GOV.UK Design System (govuk-frontend, govuk-components, govuk_design_system_formbuilder), Devise + 2FA, Pundit, PaperTrail.

Full domain/architecture docs live in `docs/` (rendered at https://communitiesuk.github.io/submit-social-housing-lettings-and-sales-data) and are the authoritative reference — especially `docs/index.md` (domain overview), `docs/form/*` (form architecture), `docs/bulk_upload.md`, `docs/exports.md`, `docs/csv_downloads.md`, and the ADRs in `docs/adr/`.

## Commands

Run app (Rails + Sidekiq's redis + JS watch via Foreman):

```bash
./bin/dev
```

Rails server alone: `bundle exec rails s` (port 3000). JS watch alone: `yarn build --mode=development --watch`. First-time asset build: `yarn build --mode=development`.

Tests:

```bash
bundle exec rspec                          # full suite
bundle exec rspec ./spec/path/to/file.rb   # single file
bundle exec rspec ./spec/path/to/file.rb:42 # single example by line
bundle exec rake parallel:setup            # one-time setup
RAILS_ENV=test bundle exec rake parallel:spec  # parallel run
```

If you change the schema, run `bundle exec rake db:migrate RAILS_ENV=test` before running specs.

Lint (everything): `bundle exec rake lint`. Individual linters:

```bash
bundle exec rubocop          # -a safe autocorrect, -A all
bundle exec erb_lint --lint-all
yarn standard                # --fix to autocorrect
yarn stylelint app/frontend/styles
yarn prettier . --check      # --write to autocorrect
```

Database: `bundle exec rake db:create db:migrate db:seed`. Seeded users use the password from `REVIEW_APP_USER_PASSWORD` in `.env` (default `password`).

## Architecture

### The form system (core abstraction)

Form data collection runs on annual windows (1 April → 1 April + 3-month late-submission tail). Two forms may be active simultaneously during the April–June/July **crossover period**.

`FormHandler` (singleton, `app/models/form_handler.rb`) holds every active form: `current/previous/next/archived` × `lettings/sales`. Each `Form` is built from Ruby classes (not JSON — historical JSON definitions in `config/forms/` are legacy; new forms are defined in code under `app/models/form/lettings/{sections,subsections,pages,questions}` and `app/models/form/sales/...`).

Hierarchy: `Form` → `Section` → `Subsection` → `Page` → `Question`. Pages route via `depends_on` conditions (with chained method calls e.g. `{ "owning_organisation.provider_type": "local_authority" }`) or custom `routed_to?` methods. Questions can be `conditional_for` (inline conditional on the same page), `derived` (computed, not cleared when unrouted), or `inferred` (cleared when their source changes). See `docs/form/builder.md` for the full DSL.

Key consequence: **every question id must match an ActiveRecord column on `LettingsLog` / `SalesLog`**. Checkbox questions need one column per answer option. Adding a question is a migration + form class change in lock-step.

`Form::DEADLINES` in `app/models/form.rb` is the source of truth for collection year cutoffs (new_logs_end_date, submission_deadline, edit_end_date). Add a year here when introducing a new collection window.

### Logs

`LettingsLog` and `SalesLog` (both inherit shared behaviour from `Log`) are the primary records. Sales splits into discounted ownership, shared-ownership initial, and staircasing (post-2024); pre-2025 also included outright sales. Lettings splits into general needs and supported housing (which belongs to a `Scheme` with one or more `Location`s).

Validations live in `app/models/validations/` (lettings) and `app/models/validations/sales/` and are mixed into the log models. Soft validations show interruption pages instead of hard errors.

### Organisations & permissions

Three user roles outside of MHCLG: **data providers**, **data coordinators** (org admins, can also complete logs), plus an optional **data protection officer (DPO)** flag on a user. Internal roles: **support** (full admin) and **statisticians**. Orgs form parent/child stock-owning/managing relationships (many-to-many), and a user's access to a log depends on whether their org owns or manages it. Pundit policies in `app/policies/` enforce this — always check the policy when adding controller actions.

### Bulk upload

Users upload a CSV per log-type per year; the file is saved to S3 and `ProcessBulkUploadJob` runs `BulkUpload::Processor`, which picks year- and type-specific `CsvParser`, `RowParser`, `Validator`, and `LogCreator` classes from `app/services/bulk_upload/`. Outcomes: clean upload, partial upload (requires user approval after error email), or rejected (template/critical errors). See `docs/bulk_upload.md`.

### Exports to CDS

`Exports::ExportService` orchestrates a nightly Sidekiq cron job that writes XML + manifests to S3 for ingestion by the Consolidated Data Store. Year-specific collections (lettings logs) can produce up to three concurrent collections during crossover. Field-level mapping lives in `lettings_log_export_service.rb`, `organisation_export_service.rb`, `user_export_service.rb`, gated by `EXPORT_FIELDS` constants in the matching `*_export_constants.rb` files (with `POST_<YEAR>_EXPORT_FIELDS` for year-gated additions). Partial vs full export semantics are documented in `docs/exports.md`.

### CSV downloads

User-facing CSV downloads are also async via Sidekiq, delivered as S3 presigned URLs by email. Logs CSVs come in **labels** (human-readable) and **codes** (numeric, aligned with bulk upload / CDS) variants. Column selection lives in `lettings_log_attributes` / `sales_log_attributes` / `scheme_attributes` / `location_attributes` and (for users) `User.download_attributes`. Header descriptions live in the `csv_variable_definitions` table and are edited via `/admin`.

### Rake tasks

`lib/tasks/` holds many one-off and operational rake tasks (data corrections, migrations, exports, form-definition dumps). For ad-hoc production runs, tasks are executed as ECS Fargate tasks against `core-$env-ad-hoc` — see `docs/rake.md`.

### Feature toggles

`app/services/feature_toggle.rb` — simple class methods, no external flag service.

### Frontend conventions

- Service-specific components live in `app/components/` (ViewComponent), with `app-*` BEM class names to avoid clashing with the `govuk-*` Design System.
- Stimulus controllers: register in `app/frontend/controllers/index.js` (kebab-case) and define in `app/frontend/controllers/` (underscore_case).
- Webpack bundles JS/CSS via `jsbundling-rails` + `cssbundling-rails`; Propshaft serves the bundled assets. Babel transpiles to ES5 for IE compatibility (polyfills in `app/frontend/application.js`).

## Testing notes

- Prefer request specs over feature specs (faster, still cover route + controller + model + view). Use feature specs only when JavaScript or interaction-specific assertions are needed.
- FactoryBot factories have deep callback chains: creating a `lettings_log`/`sales_log` also creates a `User`, `Organisation`, often a `DataProtectionConfirmation`, and an `OrganisationRentPeriod` (lettings only, if `period` is set). See `docs/testing.md` for the full breakdown — be aware that tests appearing to "just create a log" may be persisting several other records.
- Capybara runs headless by default and uses Gecko driver for `js: true` specs (toggle in `spec/rails_helper.rb`).

## Commit & PR conventions

Commits and PRs are prefixed with the Jira ticket id (e.g. `CLDC-4300: ...`) — see `git log` for examples. Pre-commit hooks (Overcommit) run RuboCop and schema-up-to-date checks; do not skip them.
