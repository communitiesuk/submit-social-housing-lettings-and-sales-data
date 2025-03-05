import { Controller } from '@hotwired/stimulus'

const profitStatusSelect = document.getElementById('organisation-profit-status-field');
const localAuthorityOption = profitStatusSelect.querySelector('option[value="local_authority"]');
const nonProfitOption = profitStatusSelect.querySelector('option[value="non_profit"]');
const profitOption = profitStatusSelect.querySelector('option[value="profit"]');
export default class extends Controller {
  updateProfitStatusOptions(event) {
    const providerType = event.target.value;

    if (profitStatusSelect) {
      profitStatusSelect.disabled = false;
      localAuthorityOption.hidden = false;
      nonProfitOption.hidden = false;
      profitOption.hidden = false;

      if (providerType === "LA") {
        profitStatusSelect.value = "local_authority";
        nonProfitOption.hidden = true;
        profitOption.hidden = true;
      } else if (providerType === "PRP") {
        profitStatusSelect.value = "";
        localAuthorityOption.hidden = true;
      }
    }
  }
}
