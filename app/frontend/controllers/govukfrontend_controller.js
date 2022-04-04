import GOVUKFrontend from "govuk-frontend";
import GOVUKPrototypeComponents from "govuk-prototype-components"
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    GOVUKFrontend.initAll()
    GOVUKPrototypeComponents.initAll()
  }
}
