import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  initialize () {
    this.clearIfHidden()
  }

  clearIfHidden () {
    if (this.element.style.display === 'none') {
      this.element.value = ''
    }
  }
}
