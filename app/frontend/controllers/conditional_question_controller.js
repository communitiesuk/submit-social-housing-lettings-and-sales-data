import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  initialize () {
    this.displayConditional()
  }

  displayConditional () {
    if (this.element.checked) {
      const selectedValue = this.element.value
      const dataInfo = JSON.parse(this.element.dataset.info)
      const conditionalFor = dataInfo.conditional_questions
      const type = dataInfo.type

      Object.entries(conditionalFor).forEach(([targetQuestion, conditions]) => {
        if (!conditions.map(String).includes(String(selectedValue))) {
          const textNumericInput = document.getElementById(`${type}-${targetQuestion.replaceAll('_', '-')}-field`)
          const errorInput = document.getElementById(`${type}-${targetQuestion.replaceAll('_', '-')}-field-error`)
          const dateInputs = [1, 2, 3].map((idx) => {
            return document.getElementById(`lettings_log_mrcdate_${idx}i`)
          })
          this.clearTextInput(textNumericInput)
          this.clearTextInput(errorInput)
          this.clearDateInputs(dateInputs)
        }
      })
    }
  }

  clearTextInput (input) {
    if (input != null) {
      input.value = ''
    }
  }

  clearDateInputs (inputs) {
    inputs.forEach((input) => {
      this.clearTextInput(input)
    })
  }
}
