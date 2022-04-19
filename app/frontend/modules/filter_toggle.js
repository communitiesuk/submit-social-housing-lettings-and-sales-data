export class FilterToggle {
  constructor (options) {
    this.options = options
    this.container = this.options.toggleButton.container
  }

  setupResponsiveChecks () {
    this.mq = window.matchMedia(this.options.bigModeMediaQuery)
    this.mq.addListener(this.checkMode.bind(this))
    this.checkMode(this.mq)
  }

  checkMode (mq) {
    if (mq.matches) {
      this.enableBigMode()
    } else {
      this.enableSmallMode()
    }
  }

  enableBigMode () {
    this.showMenu()
    this.removeMenuButton()
    this.removeCloseButton()
  }

  enableSmallMode () {
    this.options.filter.container.setAttribute("tabindex", "-1")
    this.hideMenu()
    this.addMenuButton()
    this.addCloseButton()
  }

  addCloseButton () {
    if (this.options.closeButton) {
      this.closeButton = document.createElement("button")
      this.closeButton.classList.add("app-filter__close")
      this.closeButton.innerText = this.options.closeButton.text
      this.closeButton.type = 'button'
      this.closeButton.addEventListener('click', this.onCloseClick.bind(this))

      this.options.closeButton.container.append(this.closeButton)
    }
  }

  onCloseClick () {
    this.hideMenu()
    this.menuButton.focus()
  }

  removeCloseButton () {
    if (this.closeButton) {
      this.closeButton.remove()
      this.closeButton = null
    }
  }

  addMenuButton () {
    this.menuButton = document.createElement("button")
    this.menuButton.setAttribute("aria-expanded", "false")
    this.menuButton.setAttribute("aria-has-popup", "true")
    this.menuButton.classList.add("govuk-button", this.options.toggleButton.classes, "app-filter-toggle__button")
    this.menuButton.innerText = this.options.toggleButton.showText
    this.menuButton.type = "button"
    this.menuButton.addEventListener("click", this.onMenuButtonClick.bind(this))

    this.options.toggleButton.container.prepend(this.menuButton)
  }

  removeMenuButton () {
    if (this.menuButton) {
      this.menuButton.remove()
      this.menuButton = null
    }
  }

  hideMenu () {
    if (this.menuButton) {
      this.menuButton.setAttribute("aria-expanded", "false")
      this.menuButton.innerText = this.options.toggleButton.showText
    }
    this.options.filter.container.setAttribute("hidden", true)
  }

  showMenu () {
    if (this.menuButton) {
      this.menuButton.setAttribute("aria-expanded", "true")
      this.menuButton.innerText = this.options.toggleButton.hideText
    }
    this.options.filter.container.removeAttribute("hidden")
  }

  onMenuButtonClick () {
    this.toggle()
  }

  toggle () {
    if (this.options.filter.container.hidden) {
      this.showMenu()
      this.options.filter.container.focus()
    } else {
      this.hideMenu()
    }
  }

  init () {
    this.setupResponsiveChecks()
    if (this.options.startHidden) {
      this.hideMenu()
    }
  }
}
