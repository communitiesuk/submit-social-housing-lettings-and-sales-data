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
      const logType = dataInfo.log_type

      Object.entries(conditionalFor).forEach(([targetQuestion, conditions]) => {
        if (!conditions.map(String).includes(String(selectedValue))) {
          const textNumericInput = document.getElementById(`${logType}-log-${targetQuestion.replaceAll('_', '-')}-field`)
          if (textNumericInput == null) {
            const dateInputs = [1, 2, 3].map((idx) => {
              return document.getElementById(`${logType}_log_${targetQuestion}_${idx}i`)
            })
            this.clearDateInputs(dateInputs)
          } else {
            this.clearTextNumericInput(textNumericInput)
          }
        }
      })
    }
  }

  clearTextNumericInput (input) {
    input.value = ''
  }

  clearDateInputs (inputs) {
    inputs.forEach((input) => { input.value = '' })
  }
}
