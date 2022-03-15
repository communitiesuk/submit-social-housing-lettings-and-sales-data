import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  initialize() {
    this.displayConditional()
  }

  displayConditional() {
    if(this.element.checked) {
      let selectedValue = this.element.value
      let conditional_for = JSON.parse(this.element.dataset.info)
      Object.entries(conditional_for).map(([targetQuestion, conditions]) => {
          if(conditions.map(String).includes(String(selectedValue))) {
          } else {
            const textNumericInput = document.getElementById(`case-log-${targetQuestion.replaceAll("_","-")}-field`)
            if (textNumericInput == null) {
              const dateInputs = [1,2,3].map((idx) => {
                return document.getElementById(`case_log_${targetQuestion}_${idx}i`)
              })
              this.clearDateInputs(dateInputs)
            } else {
              this.clearTextNumericInput(textNumericInput)
          }
        }
      })
    }
  }

  clearTextNumericInput(input) {
    input.value = ""
  }

  clearDateInputs(inputs) {
    inputs.forEach((input) => { input.value = "" })
  }
}
