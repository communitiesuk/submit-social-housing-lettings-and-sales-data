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
import Modernizr from "modernizr"
require.context("govuk-frontend/govuk/assets")
import { initAll } from "govuk-frontend"
import "./styles/application.scss"
import "./controllers"

function loadTurbo () {
    import('@hotwired/turbo-rails').then((turbo) => {
        console.log('imported Turbo')
        console.log(turbo)
    }).catch((err) => {
        console.log('Error loading turbo')
    })
}

if (Modernizr.fetch && Modernizr.websockets) {
    loadTurbo()
} else {
    console.log('skipped importing Turbo. Fetch API unsupported by browser.')
}

// import '@hotwired/turbo-rails'
initAll()
