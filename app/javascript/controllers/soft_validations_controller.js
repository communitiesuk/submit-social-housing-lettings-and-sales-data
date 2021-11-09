import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "override" ]

  initialize() {
    let url = window.location.href + "/soft_validations"
    this.fetch_retry(url, { headers: { accept: "application/json" } }, 2)
  }

  fetch_retry(url, options, n) {
    let self = this
    let div = this.overrideTarget
    fetch(url, options)
      .then(response => response.json())
      .then((response) => {
        if(response["show"]){
          div.style.display = "block"
          let innerHTML = div.innerHTML
          innerHTML = innerHTML.replace("soft-validations-placeholder-message", response["label"])
          innerHTML = innerHTML.replace("soft-validations-placeholder-hint-text", response["hint"])
          div.innerHTML = innerHTML
        } else {
          div.style.display = "none"
          let buttons = document.getElementsByName(`case_log[override_net_income_validation][]`)
          Object.entries(buttons).map(([idx, button]) => {
            button.checked = false
          })
        }
      })
      .catch(function(error) {
        if (n === 1) throw error
        return self.fetch_retry(url, options, n - 1)
      })
  }
}
