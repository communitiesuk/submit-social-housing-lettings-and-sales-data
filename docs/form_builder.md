## Single log submission form configuration

### Background

Lettings and Sales of Social housing data is collected in annual "collection windows" that run from 1st April to 1st April. During this window the form and questions generally stay constant. The form will generally change by small amounts between each collection window. Typical changes are adding new questions, adding or removing answer options from questions or tweaking question wording for clarity.

A paper form is produced for guidance and to help data providers collect the data offline, and a bulk upload template is circulated which need to match the online form.

Data is accepted for a collection window for up to 3 months after it's finished to allow for late data submission. This means that between April and July two version of the form run simultaneously.

Other considerations that went into our design are being able to re-use as much of this solution for other data collections, and possibly having the ability to generate the form and/or form changes from a UI.

We haven't used micro-services, preferring to deploy a single application for CLDC but we have modelled the form itself as configuration in the form of a JSON structure that acts as a sort of DSL/form builder for the form. The idea is to decouple the code that creates the required routes, controller methods, views etc to display the form from the actual wording of questions or order of pages such that it becomes possible to make changes to the form with little or no code changes.

This should also mean that in the future it could be possible to create a UI that can construct the JSON config, which would open up the ability to make form changes to a wider audience. Doing this fully would require generating and running the necessary migrations for data storage, generating the required ActiveRecord methods to validate the data server side, and generating/updating API endpoints and documentation. All of this is likely to be beyond the scope of initial MVP but could be looked at in the future.

Since initially the JSON config will not create database migrations or ActiveRecord model validations, it will instead assume that these have been correctly created for the config provided. The reasoning for this is the following assumptions:

- The form will be tweaked regularly (amending questions wording, changing the order of questions or the page a question is displayed on)
- The actual data collected will change very infrequently. Time series continuity is very important to ADD (Analysis and Data Directorate) so the actual data collected should stay largely consistent i.e. in general we can change the question wording in ways that makes the intent clearer or easier to understand, but not in ways that would make the data provider give a different answer.

A form parser class will parse this config into ruby objects/methods that can be used as an API by the rest of the application, such that we could change the underlying config if needed (for example swap JSON for YAML or for DataBase objects) without needing to change the rest of the application. We'll call this the "Form Runner" part of the application.

### Setup this log

The setup this log section is treated slightly differently from the rest of the form. It is more accurately viewed as providing metadata about the form than as being part of the form itself. It also needs to know far more about the application specific context than other parts of the form such as who the current user is, what organisation they're part of and what role they have etc.

As a result it's not modelled as part of the config but rather as code. It still uses the same "Form Runner" components though.

### Features the Form Config supports

- Defining sections, subsections, pages and questions that fit the GovUK tasklist pattern
- Text, Numeric, Date, Radio, Select and Checkbox question types
- Conditional questions (`conditional_for`) - Radio and Checkbox questions can support "conditional" text or numeric questions that show/hide on the same page when the triggering option is selected
- Routing (`depends_on`) - all pages can specify conditions (attributes of the case log) that determine whether or not they're shown to the user
  - Methods can be chained (i.e. you can have conditions in the form `{ owning_organisation.provider_type: "local_authority"`) which will call `case_log.owning_organisation.provider_type` and compare the result to the provided value.
  - Numeric questions support math expression depends_on conditions such as `{ age2: ">16" }`
- By default questions on pages that are not routed to are assumed to be invalid and are cleared. This can be prevented by setting `derived: true` on a question.
- Questions can be optionally hidden from the check answers page of each section by setting `hidden_in_check_answers: true`. This can also take a condition.
- Questions can be set as being inferred from other answers. This is similar to derived with the difference being that derived questions can be derived from anything not just other form question answers, and inferred answers are cleared when the answers they depend on change, whereas derived questions aren't.
- Soft validation interruption pages can be included
- For complex html guidance partials can be referenced

### JSON Config

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

### Improvements that could be made

- JSON schema definition could be expanded such that we can better automatically validate that a given config is valid and internally consistent
- Generators could parse a given valid JSON form and generate the required database migrations to ensure all the expected fields exist and are of a compatible type
- The parsed form could be visualised using something like GraphViz to help manually verify the coded config meets requirements
