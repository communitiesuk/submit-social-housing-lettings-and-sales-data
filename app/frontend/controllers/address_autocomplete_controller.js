import {Controller} from '@hotwired/stimulus'
import accessibleAutocomplete from 'accessible-autocomplete'
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css'
import {searchableName} from "../modules/search";

const options = []

const fetchOptions = async (query) => {
  const response = await fetch(`/address_options?query=${query}`)
  const data = await response.json()
  console.log(data)
  return data
}

const fetchAndPopulateSearchResults = async (query, populateResults, populateOptions, selectEl) => {
  if (/\S/.test(query)) {
    const results = await fetchOptions(query)
    console.log(results) // address and uprn keys returned per result
    populateOptions(results, selectEl)
    populateResults(Object.values(results).map((o) => o.address))
    // populateResults(results)
  }
}

const populateOptions = (results, selectEl) => {
  selectEl.innerHTML = ''

  results.forEach((result) => {
    const option = document.createElement('option')
    option.value = result.uprn
    option.innerHTML = result.address
    option.setAttribute('address', result.address)
    selectEl.appendChild(option)
    options.push(option)
  })
}

// const populateOptions = (results, selectEl) => {
//   selectEl.innerHTML = ''
//
//   Object.keys(results).forEach((key) => {
//     const option = document.createElement('option')
//     option.value = key
//     option.innerHTML = results[key].value
//     if (results[key].hint) { option.setAttribute('data-hint', results[key].hint) }
//     option.setAttribute('text', searchableName(results[key]))
//     selectEl.appendChild(option)
//     options.push(option)
//   })
// }

export default class extends Controller {
  connect () {
    const selectEl = this.element

    const currentValue = this.getCurrentValue()
    console.log(selectEl)

    if (currentValue && currentValue.stored_value) {
      console.log(currentValue)
      const option = document.createElement('option')
      option.value = currentValue.stored_value.uprn
      option.innerHTML = currentValue.stored_value.address
      option.selected = true
      selectEl.appendChild(option)
    }

    accessibleAutocomplete.enhanceSelectElement({
      defaultValue: '',
      selectElement: selectEl,
      minLength: 1,
      source: (query, populateResults) => {
        fetchAndPopulateSearchResults(query, populateResults, populateOptions, selectEl)
      },
      autoselect: true,
      showNoOptionsFound: true,
      placeholder: currentValue?.stored_value?.address || 'Start typing to search',
      templates: { suggestion: (value) => value },
      onConfirm: (val) => {
        const selectedResult = Array.from(selectEl.options).find(option => option.address === val)

        if (selectedResult) {
          selectedResult.selected = true
        }
      }
    })
  }

  fetchOptions(query, populateResults) {
    fetch(`/address_options?query=${query}`)
      .then(response => response.json())
      .then(data => {
        console.log(data)
        const results = data.map(result => result.uprn)
        populateResults(results.slice(0, 10))
      })
  }

  async getCurrentValue() {
    const currentPageUrl = window.location.href;
    console.log(currentPageUrl);
    const match = currentPageUrl.match(/sales-logs\/(\d+)\/address-search/);
    const id = match ? match[1] : null;

    if (id) {
      const response = await fetch(`/address_options/current?log_id=${id}`);
      const data = await response.json();
      console.log(data);
      return data;
    }

    return null;
  }

}
