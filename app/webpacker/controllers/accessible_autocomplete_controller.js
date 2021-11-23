import { Controller } from "@hotwired/stimulus"
import accessibleAutocomplete from "accessible-autocomplete"

export default class extends Controller {
  initialize() {
    accessibleAutocomplete.enhanceSelectElement({
      defaultValue: '',
      selectElement: this.element
    })
  }
}
