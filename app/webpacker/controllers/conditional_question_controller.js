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
        break;
    }
  }

  displayConditionalRadio() {
    if(this.element.checked) {
      let selectedValue = this.element.value
      let conditional_for = JSON.parse(this.element.dataset.info)
      Object.entries(conditional_for).map(([targetQuestion, conditions]) => {
        let input = document.getElementById(`case-log-${targetQuestion.replaceAll("_","-")}-field`)
        if(conditions.includes(selectedValue)) {
        } else {
          input.value = ""
        }
      })
    }
  }

  displayConditionalNumeric() {
    let enteredValue = this.element.value
    let conditional_for = JSON.parse(this.element.dataset.info)

    Object.entries(conditional_for).map(([targetQuestion, condition]) => {
      let div = document.getElementById(targetQuestion + "_div")
      if(eval((enteredValue + condition))) {
        div.style.display = "block"
      } else {
        div.style.display = "none"
      }
    })
  }
}
