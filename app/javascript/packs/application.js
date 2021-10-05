// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
require.context('govuk-frontend/govuk/assets')

import '../styles/application.scss'
import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import { initAll } from 'govuk-frontend'
import "@hotwired/turbo-rails"


Rails.start()
ActiveStorage.start()
initAll()

import "controllers"
import './tasklist'

