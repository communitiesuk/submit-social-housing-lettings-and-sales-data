import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const affectedField = this.element.dataset.target;
    const targetQuestion = affectedField.split("case-log-")[1].split("-field")[0]
    const div = document.getElementById(targetQuestion + "_div");
    div.style.display = "block";
  }

  calculateFields() {
    const affectedField = this.element.dataset.target;
    const fieldsToAdd = JSON.parse(this.element.dataset.calculated).map(x => `case-log-${x.replaceAll("_","-")}-field`);
    const valuesToAdd = fieldsToAdd.map(x => document.getElementById(x).value).filter(x => x);
    const newValue =  valuesToAdd.map(x => parseInt(x)).reduce((a, b) => a + b, 0);
    const elementToUpdate = document.getElementById(affectedField);
    elementToUpdate.value = newValue;
  }
}
