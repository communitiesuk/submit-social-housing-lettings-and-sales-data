import { Controller } from "stimulus"

export default class extends Controller {
  displayConditional() {
    let question = this.element.name;
    let selected = this.element.value;
    let conditional_for = JSON.parse(this.element.dataset.info);

    Object.entries(conditional_for).forEach(([key, values]) => {
      if(values.includes(selected)) {
        document.getElementById(key + "_div").style.display = "block"
      } else {
        document.getElementById(key + "_div").style.display = "none"
      }
    });
  }
}
