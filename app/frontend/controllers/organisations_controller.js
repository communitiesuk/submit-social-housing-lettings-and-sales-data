import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  updateProfitStatusOptions(event) {
    const providerType = event.target.value;
    const profitStatusSelect = document.getElementById('organisation-profit-status-field');

    if (profitStatusSelect) {
      profitStatusSelect.disabled = false;

      if (providerType === "LA") {
        profitStatusSelect.value = "3";
        profitStatusSelect.disabled = true;
      }
    }
  }
}
