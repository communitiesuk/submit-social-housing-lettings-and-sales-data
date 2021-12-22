import { Controller } from "@hotwired/stimulus"
import accessibleAutocomplete from "accessible-autocomplete"
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css'

export default class extends Controller {
  connect() {
    accessibleAutocomplete.enhanceSelectElement({
      defaultValue: '',
      selectElement: this.element.querySelector('input')
    })
  }
}
