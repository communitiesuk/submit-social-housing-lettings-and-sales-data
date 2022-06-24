## Single log submission form configuration

The form for this is driven by a JSON file in `/config/forms/{start_year}_{end_year}.json`

The JSON should follow the structure:

```jsonc
{
  "form_type": "lettings" / "sales",
  "start_year": Integer, // i.e. 2020
  "end_year": Integer, // i.e. 2021
  "sections": {
    "[snake_case_section_name_string]": {
      "label": String,
      "description": String,
      "subsections": {
        "[snake_case_subsection_name_string]": {
          "label": String,
          "pages": {
            "[snake_case_page_name_string]": {
              "header": String,
              "description": String,
              "questions": {
                "[snake_case_question_name_string]": {
                  "header": String,
                  "hint_text": String,
                  "check_answer_label": String,
                  "type": "text" / "numeric" / "radio" / "checkbox" / "date",
                  "min": Integer, // numeric only
                  "max": Integer, // numeric only
                  "step": Integer, // numeric only
                  "width": 2 / 3 / 4 / 5 / 10 / 20, // text and numeric only
                  "prefix": String, // numeric only
                  "suffix": String, //numeric only
                  "answer_options": { // checkbox and radio only
                    "0": String,
                    "1": String
                  },
                  "conditional_for": {
                    "[snake_case_question_to_enable_1_name_string]": ["condition-that-enables"],
                    "[snake_case_question_to_enable_2_name_string]": ["condition-that-enables"]
                  },
                  "inferred_answers": { "field_that_gets_inferred_from_current_field": { "is_that_field_inferred": true } },
                  "inferred_check_answers_value": {
                    "condition": { "field_name_for_inferred_check_answers_condition": "field_value_for_inferred_check_answers_condition" },
                    "value": "Inferred value that gets displayed if condition is met"
                  }
                }
              },
              "depends_on": [{ "question_key": "answer_value_required_for_this_page_to_be_shown" }]
            }
          }
        }
      }
    }
  }
}
```

Assumptions made by the format:

- All forms have at least 1 section
- All sections have at least 1 subsection
- All subsections have at least 1 page
- All pages have at least 1 question
- The ActiveRecord case log model has a field for each question name (must match). In the case of checkbox questions it must have one field for every answer option (again names must match).
- Text not required by a page/question such as a header or hint text should be passed as an empty string
- For conditionally shown questions, conditions that have been implemented and can be used are:
  - Radio question answer option selected matches one of conditional e.g. ["answer-options-1-string", "answer-option-3-string"]
  - Numeric question value matches condition e.g. [">2"], ["<7"] or ["== 6"]
- When the top level question is a radio button and the conditional question is a numeric, text or date field then the conditional question is shown inline
- When the conditional question is a radio, checkbox or select field it should be displayed on it's own page and "depends_on" should be used rather than "conditional_for"

  Page routing:

  - Form navigation works by stepping sequentially through every page defined in the JSON form definition for the given subsection. For every page it checks if it has "depends_on" conditions. If it does, it evaluates them to determine whether that page should be show or not.

  - In this way we can build up whole branches by having:

  ```jsonc
  "page_1": { "questions": { "question_1: "answer_options": ["A", "B"] } },
  "page_2": { "questions": { "question_2: "answer_options": ["C", "D"] }, "depends_on": [{ "question_1": "A" }] },
  "page_3": { "questions": { "question_3: "answer_options": ["E", "F"] }, "depends_on": [{ "question_1": "A" }] },
  "page_4": { "questions": { "question_4: "answer_options": ["G", "H"] }, "depends_on": [{ "question_1": "B" }] },
  ```

### JSON form validation against Schema

To validate the form JSON against the schema you can run:\
  `rake form_definition:validate["config/forms/2021_2022.json"]`

n.b. You may have to escape square brackets in zsh\
  `rake form_definition:validate\["config/forms/2021_2022.json"\]`

This will validate the given form definition against the schema in `config/forms/schema/generic.json`.

You can also run:\
  `rake form_definition:validate_all`

This will validate all forms in directories = `["config/forms", "spec/fixtures/forms"]`
