// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application
// logic in a relevant structure within app/javascript and only use these pack
// files to reference that code so it'll be compiled.

// Polyfills for IE
import '@stimulus/polyfills'
import '@webcomponents/webcomponentsjs'
import 'core-js/stable'
import 'custom-event-polyfill'
import 'intersection-observer'
import 'regenerator-runtime/runtime'

//
import { initAll as GOVUKFrontend } from 'govuk-frontend'
import { initAll as GOVUKPrototypeComponents } from 'govuk-prototype-components'
import './controllers'
import './cookie-banner'
import './styles/application.scss'

require.context('govuk-frontend/govuk/assets')

GOVUKFrontend()
GOVUKPrototypeComponents()
