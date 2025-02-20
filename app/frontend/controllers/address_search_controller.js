import { Controller } from '@hotwired/stimulus'
import accessibleAutocomplete from 'accessible-autocomplete'
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css'

const options = []

const fetchOptions = async (query, searchUrl) => {
  const response = await fetch(`${searchUrl}?query=${encodeURIComponent(query)}`)
  return await response.json()
}

const fetchAndPopulateSearchResults = async (query, populateResults, searchUrl, populateOptions, selectEl) => {
  if (/\S/.test(query)) {
    const results = await fetchOptions(query, searchUrl)
    populateOptions(results, selectEl)
    populateResults(Object.values(results).map((o) => o.text))
  }
}

const populateOptions = (results, selectEl) => {
  selectEl.innerHTML = ''

  results.forEach((result) => {
    const option = document.createElement('option')
    option.value = result.value
    option.innerHTML = result.text
    selectEl.appendChild(option)
    options.push(option)
  })
}

export default class extends Controller {
  connect () {
    const searchUrl = JSON.parse(this.element.dataset.info).search_url
    const selectEl = this.element

    accessibleAutocomplete.enhanceSelectElement({
      defaultValue: '',
      selectElement: selectEl,
      minLength: 3,
      source: (query, populateResults) => {
        fetchAndPopulateSearchResults(query, populateResults, searchUrl, populateOptions, selectEl)
      },
      autoselect: true,
      showNoOptionsFound: true,
      placeholder: 'Start typing to search',
      templates: { suggestion: (value) => value },
      onConfirm: (val) => {
        const selectedResult = Array.from(selectEl.options).find(option => option.text === val)
        if (selectedResult) {
          selectedResult.selected = true
        }
      }
    })
  }
}
