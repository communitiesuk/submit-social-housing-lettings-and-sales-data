import { initAll } from "govuk-frontend";
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    initAll()
  }
}
