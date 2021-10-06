import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  addHighlight() {
    let section_to_highlight = this.element.dataset.info;
    document.getElementById(section_to_highlight).classList.add('tasklist_item_highlight');
  }
}
