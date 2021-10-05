import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  initialize() {
    this.displayConditional()
  }

  displayConditional() {
    switch(this.element.type) {
      case "number":
        this.displayConditionalNumeric()
      case "radio":
        this.displayConditionalRadio()
      default:
        console.log("Not yet implemented for " + this.element.type)
        break;
    }
  }

  displayConditionalRadio() {
    if(this.element.checked) {
      let value = this.element.value
      let conditional_for = JSON.parse(this.element.dataset.info)

      Object.entries(conditional_for).forEach(([key, values]) => {
        let div = document.getElementById(key + "_div")
        if(values.includes(value)) {
          div.style.display = "block"
        } else {
          div.style.display = "none"
          let buttons = document.getElementsByName(`case_log[${key}]`)
          Object.entries(buttons).forEach(([idx, button]) => {
            button.checked = false;
          })
        }
      })
    }
  }

  displayConditionalNumeric() {
    let value = this.element.value
    let conditional_for = JSON.parse(this.element.dataset.info)

    Object.entries(conditional_for).forEach(([key, values]) => {
      let div = document.getElementById(key + "_div")
      if(eval((value + values))) {
        div.style.display = "block"
      } else {
        div.style.display = "none"
      }
    })
  }
}
