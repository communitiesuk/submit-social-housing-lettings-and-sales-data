import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ["groupSelect"]

  connect() {
    this.toggleGroupSelect()
  }

  toggleGroupSelect() {
    const groupMemberYes = this.element.querySelector('input[name="organisation[group_member]"]:checked')?.value === 'true'
    this.groupSelectTarget.style.display = groupMemberYes ? 'block' : 'none'
  }
}
