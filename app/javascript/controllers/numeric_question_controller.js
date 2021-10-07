import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  calculateFields() {
    const affectedField = this.element.dataset.target;
    const fieldsToAdd = JSON.parse(this.element.dataset.calculated).map(x => `${x.replaceAll("_","-")}-field`);
    const valuesToAdd = fieldsToAdd.map(x => document.getElementById(x).value).filter(x => x);
    const newValue =  valuesToAdd.map(x => parseInt(x)).reduce((a, b) => a + b, 0);
    const elementToUpdate = document.getElementById(affectedField);
    elementToUpdate.value = newValue;
  }
}
