import { initAll as GOVUKFrontend } from 'govuk-frontend'
import { initAll as GOVUKPrototypeComponents } from 'govuk-prototype-components'
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    GOVUKFrontend()
    GOVUKPrototypeComponents()
  }
}
