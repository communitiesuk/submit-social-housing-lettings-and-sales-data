import { Controller } from "@hotwired/stimulus"
import accessibleAutocomplete from "accessible-autocomplete"
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css'

export default class extends Controller {
  static values = { enhanced: Boolean, default: false }

  connect() {
    if(!this.enhancedValue){
      accessibleAutocomplete.enhanceSelectElement({
        defaultValue: '',
        selectElement: this.element
      })
      this.enhancedValue = true
    }
  }
}
