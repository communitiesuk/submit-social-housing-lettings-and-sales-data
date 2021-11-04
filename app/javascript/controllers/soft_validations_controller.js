import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  initialize() {
    let url = window.location.href + "/soft_validations"
    let xhr = new XMLHttpRequest()
    let div = document.getElementById("soft-validations")
    xhr.open("GET", url, true)
    xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
    xhr.onreadystatechange = function () {
            if (this.readyState == 4 && this.status == 200) {
              let response = JSON.parse(this.response)
                if(response["show"]){
                  div.style.display = "block"
                  let innerHTML = div.innerHTML
                  innerHTML = innerHTML.replace("soft-validations-placeholder-message", response["label"])
                  innerHTML = innerHTML.replace("soft-validations-placeholder-hint-text", response["hint"])
                  div.innerHTML = innerHTML
                } else {
                  div.style.display = "none"
                  let buttons = document.getElementsByName(`case_log[override_net_income_validation][]`)
                  Object.entries(buttons).forEach(([idx, button]) => {
                    button.checked = false;
                  })
                }
            }
        }
    xhr.send()
  }
}
