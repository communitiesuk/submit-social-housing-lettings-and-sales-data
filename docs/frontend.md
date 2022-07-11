---
nav_order: 2
---

# Frontend

## GOV.UK Design System components

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

## Service-specific components

Service-specific components are built using the [ViewComponent](https://viewcomponent.org) framework, and can be found in `app/components`.

Components use HTML class names that follow the BEM methodology. We use the `app-*` prefix to prevent collisions with components provided by the Design System (which uses `govuk-*`). See [Extending and modifying components in production](https://design-system.service.gov.uk/get-started/extending-and-modifying-components/).

Stylesheets are written using [Sass](https://sass-lang.com) (and the SCSS syntax), using the mixins and helpers provided by [govuk-frontend](https://frontend.design-system.service.gov.uk/sass-api-reference/).

Separate stylesheets are used for each component, with filenames that match the component’s namespace.

Like the components provided by the Design System, components are progressively enhanced. We use [Stimulus](https://stimulus.hotwired.dev) to add any client-side JavaScript enhancements.

### Stimulus

For adding custom javascript to the application we use [Stimulus](https://stimulus.hotwired.dev/).

The general pattern is:

- Register a controller in `/app/frontend/controllers/index.js`- be sure to use kebab case
- Create that controller in `app/frontend/controllers/` - be sure to use underscore case
- Attach the controller to the html element that should trigger it’s functionality

### Asset bundling and compilation

- We use [Webpack](https://webpack.js.org/) via [jsbundling-rails](https://github.com/rails/jsbundling-rails) to bundle JavaScript, CSS and images. The configuration can be found in `webpack.config.js`.
- We use [Propshaft](https://github.com/rails/propshaft) as our asset pipeline to serve the assets bundled/compiled by webpack
- We use [Babel](https://babeljs.io/) to transpile js down to ES5 for Internet Explorer compatibility. The configuration can be found in `babel.config.js`
- We use [browserslist](https://github.com/browserslist/browserslist) to specify the browsers we want to transpile for. The configuration can be found in `package.json`
- We include a number of polyfills to support Internet Explorer. These can be found in `app/frontend/application.js`
