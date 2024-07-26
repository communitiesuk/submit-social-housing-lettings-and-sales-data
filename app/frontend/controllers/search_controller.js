import { Controller } from '@hotwired/stimulus'
import accessibleAutocomplete from 'accessible-autocomplete'
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css'
import { searchSuggestion, fetchAndPopulateSearchResults } from '../modules/search'

let hints = []
const populateHint = (results) => {
  hints = results
}

export default class extends Controller {
  connect () {
    const selectEl = this.element
    const selectOptions = Array.from(selectEl.options).filter(function (option, index, arr) { return option.value !== '' })

    const matches = /^(\w+)\[(\w+)\]$/.exec(selectEl.name)
    const rawFieldName = matches ? `${matches[1]}[${matches[2]}_raw]` : ''

    accessibleAutocomplete.enhanceSelectElement({
      defaultValue: '',
      selectElement: selectEl,
      minLength: 1,
      source: (query, populateResults) => {
        fetchAndPopulateSearchResults(query, populateResults, populateHint)
      },
      autoselect: true,
      placeholder: 'Start typing to search',
      templates: { suggestion: (value) => searchSuggestion(value, hints) },
      name: rawFieldName,
      onConfirm: (val) => {
        const selectedOption = [].filter.call(
          Array.from(selectEl.options).filter(function (option, index, arr) { return option.value !== '' }),
          (option) => option.value === val
        )[0]
        if (selectedOption) selectedOption.selected = true
      }
    })

    const parentElement = selectEl.parentElement
    const inputElement = parentElement.querySelector('[role=combobox]')

    inputElement.addEventListener('input', () => {
      selectOptions.forEach((option) => { option.selected = false })
    })
  }
}
