const addWeightWithBoost = (option, query) => {
  option.weight = calculateWeight(option.clean, query) * option.clean.boost

  return option
}

const clean = (text) =>
  text
    .trim()
    .replace(/['’]/g, '')
    .replace(/[.,"/#!$%^&*;:{}=\-_`~()]/g, ' ')
    .toLowerCase()

const cleanseOption = (option) => {
  const synonyms = (option.synonyms || []).map(clean)

  option.clean = {
    name: clean(option.name),
    nameWithoutStopWords: removeStopWords(option.name),
    synonyms,
    synonymsWithoutStopWords: synonyms.map(removeStopWords),
    boost: option.boost || 1
  }

  return option
}

const hasWeight = (option) => option.weight > 0

const byWeightThenAlphabetically = (a, b) => {
  if (a.weight > b.weight) return -1
  if (a.weight < b.weight) return 1
  if (a.name < b.name) return -1
  if (a.name > b.name) return 1

  return 0
}

const optionName = (option) => option.name
const exactMatch = (word, query) => word === query

const startsWithRegExp = (query) => new RegExp('\\b' + query, 'i')
const startsWith = (word, query) => word.search(startsWithRegExp(query)) === 0

const wordsStartsWithQuery = (word, regExps) =>
  regExps.every((regExp) => word.search(regExp) >= 0)

const anyMatch = (words, query, evaluatorFunc) => words.some((word) => evaluatorFunc(word, query))
const synonymsExactMatch = (synonyms, query) => anyMatch(synonyms, query, exactMatch)
const synonymsStartsWith = (synonyms, query) => anyMatch(synonyms, query, startsWith)

const wordInSynonymStartsWithQuery = (synonyms, startsWithQueryWordsRegexes) =>
  anyMatch(synonyms, startsWithQueryWordsRegexes, wordsStartsWithQuery)

const calculateWeight = ({ name, synonyms, nameWithoutStopWords, synonymsWithoutStopWords }, query) => {
  const queryWithoutStopWords = removeStopWords(query)

  if (exactMatch(name, query)) return 100
  if (exactMatch(nameWithoutStopWords, queryWithoutStopWords)) return 95

  if (synonymsExactMatch(synonyms, query)) return 75
  if (synonymsExactMatch(synonymsWithoutStopWords, queryWithoutStopWords)) return 70

  if (startsWith(name, query)) return 60
  if (startsWith(nameWithoutStopWords, queryWithoutStopWords)) return 55

  if (synonymsStartsWith(synonyms, query)) return 50
  if (synonymsStartsWith(synonyms, queryWithoutStopWords)) return 40

  const startsWithRegExps = queryWithoutStopWords
    .split(/\s+/)
    .map(startsWithRegExp)

  if (wordsStartsWithQuery(nameWithoutStopWords, startsWithRegExps)) return 25
  if (wordInSynonymStartsWithQuery(synonymsWithoutStopWords, startsWithRegExps)) return 10

  return 0
}

const stopWords = ['the', 'of', 'in', 'and', 'at', '&']

const removeStopWords = (text) => {
  const isAllStopWords = text
    .trim()
    .split(' ')
    .every((word) => stopWords.includes(word))

  if (isAllStopWords) {
    return text
  }

  const regex = new RegExp(
    stopWords.map((word) => `(\\s+)?${word}(\\s+)?`).join('|'),
    'gi'
  )
  return text.replace(regex, ' ').trim()
}

export const sort = (query, options) => {
  const cleanQuery = clean(query)

  return options
    .map(cleanseOption)
    .map((option) => addWeightWithBoost(option, cleanQuery))
    .filter(hasWeight)
    .sort(byWeightThenAlphabetically)
    .map(optionName)
}

export const suggestion = (value, options) => {
  const option = options.find((o) => o.name === value)
  if (option) {
    const html = option.append ? `<span class="autocomplete__option__append">${option.text}</span> <span>${option.append}</span>` : `<span>${option.text}</span>`
    return option.hint ? `${html}<div class="autocomplete__option__hint">${option.hint}</div>` : html
  } else {
    return '<span>No results found</span>'
  }
}

export const searchSuggestion = (value, hints) => {
  try {
    const result = hints[value.toString()]
    if (result) {
      const html = result.append ? `<span class="autocomplete__option__append">${result.value}</span> <span>${result.append}</span>` : `<span>${result.value}</span>`
      return result.hint ? `${html}<div class="autocomplete__option__hint">${result.hint}</div>` : html
    } else {
      return '<span>No results found</span>'
    }
  } catch (error) {
    console.error('Error fetching user option:', error)
    return value
  }
}

export const enhanceOption = (option) => {
  return {
    text: option.text,
    name: getSearchableName(option),
    synonyms: (option.getAttribute('data-synonyms') ? option.getAttribute('data-synonyms').split('|') : []),
    append: option.getAttribute('data-append'),
    hint: option.getAttribute('data-hint'),
    boost: parseFloat(option.getAttribute('data-boost')) || 1
  }
}

export const fetchAndPopulateSearchResults = async (query, populateResults, populateHint) => {
  if (/\S/.test(query)) {
    const results = await fetchUserOptions(query)
    populateResults(Object.keys(results))
    populateHint(results)
  }
}

export const fetchUserOptions = async (query) => {
  try {
    const response = await fetch(`/users/search?query=${encodeURIComponent(query)}`)
    const results = await response.json()
    return results
  } catch (error) {
    console.error('Error fetching user options:', error)
    return []
  }
}

export const getSearchableName = (option) => {
  return option.getAttribute('data-hint') ? option.text + ' ' + option.getAttribute('data-hint') : option.text
}
