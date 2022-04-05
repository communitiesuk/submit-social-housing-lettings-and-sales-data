import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  toggleFilter() {
    let filter_panel = document.getElementById("filter-panel");
    let toggle_filter_button = document.getElementById("toggle-filter-button");

    if (filter_panel.style.display === "none" || !filter_panel.style.display) {
      filter_panel.style.display = "block";
      toggle_filter_button.innerText = "Hide filters";
    } else {
      filter_panel.style.display = "none";
      toggle_filter_button.innerText = "Show filters";
    }
  }
}
