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
    if (results[key].hint) { option.setAttribute('data-hint', results[key].hint) }
    option.setAttribute('text', searchableName(results[key]))
    selectEl.appendChild(option)
    options.push(option)
  })
}

export default class extends Controller {
  connect () {
    const selectEl = this.element
    const matches = /^(\w+)\[(\w+)\]$/.exec(selectEl.name)
    const rawFieldName = matches ? `${matches[1]}[${matches[2]}_raw]` : ''
    const searchUrl = JSON.parse(this.element.dataset.info).search_url

    document.querySelectorAll('.non-js-text-search-input-field').forEach((el) => {
      el.style.display = 'none'
    })

    accessibleAutocomplete.enhanceSelectElement({
      defaultValue: '',
      selectElement: selectEl,
      minLength: 1,
      source: (query, populateResults) => {
        fetchAndPopulateSearchResults(query, populateResults, searchUrl, populateOptions, selectEl)
      },
      autoselect: true,
      placeholder: 'Start typing to search',
      templates: { suggestion: (value) => searchSuggestion(value, options) },
      name: rawFieldName,
      onConfirm: (val) => confirmSelectedOption(selectEl, val)
    })
  }
}
