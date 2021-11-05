import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "override" ]

  initialize() {
    let url = window.location.href + "/soft_validations"
    let div = this.overrideTarget
    fetch(url, { headers: { accept: "application/json" } })
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
      }
    )
  }
}
