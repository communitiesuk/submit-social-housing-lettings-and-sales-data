import { Controller } from '@hotwired/stimulus'
import accessibleAutocomplete from 'accessible-autocomplete'
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css'
import { searchSuggestion, fetchAndPopulateSearchResults, confirmSelectedOption, searchableName } from '../modules/search'

const options = []
const populateOptions = (results, selectEl) => {
  selectEl.innerHTML = ''

  Object.keys(results).forEach((key) => {
    const option = document.createElement('option')
    option.value = key
    option.innerHTML = searchableName(results[key])
    option.setAttribute('data-hint', results[key].hint)
    option.textContent = searchableName(results[key])
    selectEl.appendChild(option)
    options.push(option)
  })
}

export default class extends Controller {
  connect () {
    const selectEl = this.element
    const matches = /^(\w+)\[(\w+)\]$/.exec(selectEl.name)
    const rawFieldName = matches ? `${matches[1]}[${matches[2]}_raw]` : ''
    const relativeUrlRoute = JSON.parse(this.element.dataset.info).relative_url_route

    accessibleAutocomplete.enhanceSelectElement({
      defaultValue: '',
      selectElement: selectEl,
      minLength: 1,
      source: (query, populateResults) => {
        fetchAndPopulateSearchResults(query, populateResults, relativeUrlRoute, populateOptions, selectEl)
      },
      autoselect: true,
      placeholder: 'Start typing to search',
      templates: { suggestion: (value) => searchSuggestion(value, options) },
      name: rawFieldName,
      onConfirm: (val) => confirmSelectedOption(selectEl, val)
    })
  }
}
