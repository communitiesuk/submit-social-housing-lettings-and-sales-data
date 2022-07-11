import { Controller } from "@hotwired/stimulus";
import accessibleAutocomplete from "accessible-autocomplete";
import "accessible-autocomplete/dist/accessible-autocomplete.min.css";
import { enhanceOption, suggestion, sort } from "../modules/search";

export default class extends Controller {
  connect() {
    const selectEl = this.element;
    const selectOptions = Array.from(selectEl.options);
    const options = selectOptions.map((o) => enhanceOption(o));

    const matches = /^(\w+)\[(\w+)\]$/.exec(selectEl.name);
    const rawFieldName = `${matches[1]}[${matches[2]}_raw]`;

    accessibleAutocomplete.enhanceSelectElement({
      defaultValue: "",
      selectElement: selectEl,
      minLength: 2,
      source: (query, populateResults) => {
        if (/\S/.test(query)) {
          populateResults(sort(query, options));
        }
      },
      autoselect: true,
      templates: { suggestion: (value) => suggestion(value, options) },
      name: rawFieldName,
      onConfirm: (val) => {
        const selectedOption = [].filter.call(
          selectOptions,
          (option) => (option.textContent || option.innerText) === val
        )[0];
        if (selectedOption) selectedOption.selected = true;
      },
    });
  }
}
