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
  option.clean = {
    name: clean(option.name),
    nameWithoutStopWords: removeStopWords(option.name),
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

const calculateWeight = ({ name, nameWithoutStopWords }, query) => {
  const queryWithoutStopWords = removeStopWords(query)

  if (exactMatch(name, query)) return 100
  if (exactMatch(nameWithoutStopWords, queryWithoutStopWords)) return 95

  if (startsWith(name, query)) return 60
  if (startsWith(nameWithoutStopWords, queryWithoutStopWords)) return 55
  const startsWithRegExps = queryWithoutStopWords
    .split(/\s+/)
    .map(startsWithRegExp)

  if (wordsStartsWithQuery(nameWithoutStopWords, startsWithRegExps)) return 25

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
    const html = `<span>${value}</span>`
    return html
  } else {
    return '<span>No results found</span>'
  }
}

export const enhanceOption = (option) => {
  return {
    name: option.label,
    boost: parseFloat(option.getAttribute('data-boost')) || 1
  }
}
