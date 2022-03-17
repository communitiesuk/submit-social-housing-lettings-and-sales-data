// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
require.context("govuk-frontend/govuk/assets")
import "core-js/stable"
import "unfetch/polyfill"
import Modernizr from 'modernizr'

import "./styles/application.scss"
import "./controllers"

if (Modernizr.fetch) {
    import('@hotwired/turbo-rails').then(() => {
        console.log('imported Turbo')
    }).catch((err) => {
        console.log('Error loading turbo')

    })
} else {
    console.log('skipped importing Turbo. Fetch API unsupported by browser.')
}

const { initAll } = require("govuk-frontend")

initAll()
