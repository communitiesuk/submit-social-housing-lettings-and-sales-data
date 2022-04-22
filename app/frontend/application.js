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
import GOVUKFrontend from "govuk-frontend"
import GOVUKPrototypeComponents from "govuk-prototype-components"
import "./styles/application.scss"
import "./controllers"

GOVUKFrontend.initAll()
GOVUKPrototypeComponents.initAll()
