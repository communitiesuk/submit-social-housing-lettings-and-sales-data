import "@hotwired/turbo-rails"
import "./controllers"
import { initAll } from 'govuk-frontend'

Rails.start()
initAll()
