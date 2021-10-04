import { Controller } from "stimulus"

export default class extends Controller {
  displayConditional() {
    let question = this.element.name;
    let selected = this.element.value;
    let conditional_for = JSON.parse(this.element.dataset.info);

    Object.entries(conditional_for).forEach(([key, values]) => {
      let el = document.getElementById(key + "_div");
      if(values.includes(selected)) {
        el.style.display = "block";
      } else {
        el.style.display = "none";
        let buttons = document.getElementsByName(key)
        Object.entries(buttons).forEach(([idx, button]) => {
          button.checked = false;
        });
      }
    });
  }
}
