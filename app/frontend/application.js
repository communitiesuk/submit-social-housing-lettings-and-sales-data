// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// Polyfills for IE
import "regenerator-runtime/runtime"
import "@stimulus/polyfills"
import "custom-event-polyfill"
//

require.context("govuk-frontend/govuk/assets")
import { initAll } from "govuk-frontend"
import "./styles/application.scss"
import "./controllers"
import "@hotwired/turbo-rails"

initAll()
