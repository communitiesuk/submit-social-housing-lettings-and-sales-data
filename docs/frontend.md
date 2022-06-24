## Frontend

### GOV.UK Design System components

This service follows the guidance and recommendations from the [GOV.UK Design System](https://design-system.service.gov.uk). This is achieved using the following libraries:

- **GOV.UK Frontend** – CSS and JavaScript for all Design System components\
  [Documentation](https://frontend.design-system.service.gov.uk) ·
  [GitHub](https://github.com/alphagov/govuk-frontend)

- **GOV.UK Components** – Rails view components for non-form related Design System components\
  [Documentation](https://govuk-components.netlify.app) ·
  [Github](https://github.com/DFE-Digital/govuk-components) ·
  [RubyDoc](https://www.rubydoc.info/gems/govuk-components)

- **GOV.UK FormBuilder** – Rails form builder for form related Design System components\
  [Documentation](https://govuk-form-builder.netlify.app) ·
  [GitHub](https://github.com/DFE-Digital/govuk-formbuilder) ·
  [RubyDoc](https://www.rubydoc.info/gems/govuk_design_system_formbuilder)

### Service-specific components

Service-specific components are built using the [ViewComponent](https://viewcomponent.org) framework, and can be found in `app/components`.

Components use HTML class names that follow the BEM methodology. We use the `app-*` prefix to prevent collisions with components provided by the Design System (which uses `govuk-*`). See [Extending and modifying components in production](https://design-system.service.gov.uk/get-started/extending-and-modifying-components/).

Stylesheets are written using [Sass](https://sass-lang.com) (and the SCSS syntax), using the mixins and helpers provided by [govuk-frontend](https://frontend.design-system.service.gov.uk/sass-api-reference/).

Separate stylesheets are used for each component, with filenames that match the component’s namespace.

Like the components provided by the Design System, components are progressively enhanced. We use [Stimulus](https://stimulus.hotwired.dev) to add any client-side JavaScript enhancements.
