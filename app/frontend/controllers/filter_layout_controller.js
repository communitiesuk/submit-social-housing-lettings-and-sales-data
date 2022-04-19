import { Controller } from "@hotwired/stimulus";
import { FilterToggle } from "../modules/filter_toggle.js"

export default class extends Controller {
  connect() {
    const filterToggle = new FilterToggle({
      bigModeMediaQuery: '(min-width: 48.0625em)',
      closeButton: {
        container: this.element.querySelector('.app-filter__header'),
        text: 'Close'
      },
      filter: {
        container: this.element.querySelector('.app-filter-layout__filter')
      },
      startHidden: false,
      toggleButton: {
        container: this.element.querySelector('.app-filter-toggle'),
        showText: 'Show filters',
        hideText: 'Hide filters',
        classes: 'govuk-button--secondary'
      }
    })

    filterToggle.init()
  }
}
