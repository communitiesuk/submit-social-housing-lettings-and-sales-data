import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  initialize() {
    this.displayConditional()
  }

  displayConditional() {
    if(this.element.checked) {
      let selected = this.element.value
      let conditional_for = JSON.parse(this.element.dataset.info)

      Object.entries(conditional_for).forEach(([key, values]) => {
        let div = document.getElementById(key + "_div")
        if(values.includes(selected)) {
          div.style.display = "block"
        } else {
          div.style.display = "none"
          let buttons = document.getElementsByName(key)
          Object.entries(buttons).forEach(([idx, button]) => {
            button.checked = false;
          })
        }
      })
    }
  }
}
