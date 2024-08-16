document.addEventListener('DOMContentLoaded', function () {
  const urlParams = new URLSearchParams(window.location.search)
  let tab = urlParams.get('tab')

  if (!tab && window.location.hash) {
    tab = window.location.hash.substring(1)
    urlParams.set('tab', tab)
    window.history.replaceState(null, null, `${window.location.pathname}?${urlParams.toString()}`)
  }
  function activateTab (tabId) {
    const tabElement = document.getElementById(tabId)
    if (tabElement) {
      tabElement.click()
    }
    window.history.replaceState(null, null, `${window.location.pathname}?${urlParams.toString()}`)
  }

  function handleTabClick (event) {
    event.preventDefault()
    const targetId = this.getAttribute('href').substring(1)
    activateTab(targetId)
    urlParams.set('tab', targetId)
    window.history.replaceState(null, null, `${window.location.pathname}?${urlParams.toString()}`)
  }

  if (tab) {
    activateTab(`tab_${tab}`)
  }

  window.scrollTo(0, 0)

  document.querySelectorAll('.govuk-tabs__tab').forEach(tabElement => {
    tabElement.addEventListener('click', handleTabClick)
  })
})
