// Load all the controllers within this directory and all subdirectories.
// Controller files must be named *_controller.js.

import { application } from "./application"

import AccessibleAutocompleteController from "./accessible_autocomplete_controller.js"
application.register("accessible-autocomplete", AccessibleAutocompleteController)

import ConditionalQuestionController from "./conditional_question_controller.js"
application.register("conditional-question", ConditionalQuestionController)

import GovukfrontendController from "./govukfrontend_controller.js"
application.register("govukfrontend", GovukfrontendController)

import NumericQuestionController from "./numeric_question_controller.js"
application.register("numeric-question", NumericQuestionController)

import FilterLayoutController from "./filter_layout_controller.js"
application.register("filter-layout", FilterLayoutController)
