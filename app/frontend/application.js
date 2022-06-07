// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// Polyfills for IE
import "@webcomponents/webcomponentsjs"
import "core-js/stable"
import "regenerator-runtime/runtime"
import "@stimulus/polyfills"
import "custom-event-polyfill"
import "intersection-observer"
//

require.context("govuk-frontend/govuk/assets")
import { initAll as govUKFrontendInitAll } from "govuk-frontend"
import { initAll as govUKPrototypeComponentsInitAll } from "govuk-prototype-components"
import "./styles/application.scss"
import "./controllers"

govUKFrontendInitAll()
govUKPrototypeComponentsInitAll()
