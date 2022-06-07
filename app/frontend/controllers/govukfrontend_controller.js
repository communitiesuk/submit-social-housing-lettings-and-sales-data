import { initAll as govUKFrontendInitAll } from "govuk-frontend"
import { initAll as govUKPrototypeComponentsInitAll } from "govuk-prototype-components"
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    govUKFrontendInitAll()
    govUKPrototypeComponentsInitAll()
  }
}
