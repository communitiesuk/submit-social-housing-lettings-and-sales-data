import { Controller } from "@hotwired/stimulus"
import accessibleAutocomplete from "accessible-autocomplete"
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css'

export default class extends Controller {
  connect() {
    if(document.querySelectorAll(".autocomplete__input").length == 0){
      accessibleAutocomplete.enhanceSelectElement({
        defaultValue: '',
        selectElement: this.element
      })
    }
  }
}
