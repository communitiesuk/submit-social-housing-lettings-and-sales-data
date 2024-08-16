document.addEventListener("DOMContentLoaded", function() {
  const urlParams = new URLSearchParams(window.location.search);
  const tab = urlParams.get("tab");

  function activateTab(tabId) {
    const tabElement = document.getElementById(tabId);
    if (tabElement) {
      tabElement.click();
    }
    history.replaceState(null, null, `${window.location.pathname}?${urlParams.toString()}`);
  }

  function handleTabClick(event) {
    event.preventDefault();
    const targetId = this.getAttribute('href').substring(1);
    activateTab(targetId);
    urlParams.set("tab", targetId);
    history.replaceState(null, null, `${window.location.pathname}?${urlParams.toString()}`);
  }

  if (tab) {
    activateTab(`tab_${tab}`);
  }

  window.scrollTo(0, 0);

  document.querySelectorAll('.govuk-tabs__tab').forEach(tabElement => {
    tabElement.addEventListener('click', handleTabClick);
  });
});
