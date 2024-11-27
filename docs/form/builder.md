---
parent: Generating forms
nav_order: 1
---

# Form builder

## Setup this log

The setup this log section is treated slightly differently from the rest of the form. It is more accurately viewed as providing metadata about the form than as being part of the form itself. It also needs to know far more about the application specific context than other parts of the form such as who the current user is, what organisation they’re part of and what role they have etc.

## Features the Form supports

- Defining sections, subsections, pages and questions that fit the GOV.UK task list pattern

- Auto-generated routes – URLs are automatically created from dasherized page names (ids)

- Data persistence requires a database field to exist which matches the name/id for each question (and answer option for checkbox questions)

- Text, numeric, date, radio, select and checkbox question types

- Conditional questions (`conditional_for`) – Radio and checkbox questions can support conditional text or numeric questions that show/hide on the same page when the triggering option is selected

- Routing (`depends_on`) – all pages can specify conditions (attributes of the lettings log) that determine whether or not they’re shown to the user

  - Methods can be chained (i.e. you can have conditions in the form `{ owning_organisation.provider_type: "local_authority"`) which will call `lettings_log.owning_organisation.provider_type` and compare the result to the provided value.

  - Numeric questions support math expression depends_on conditions such as `{ age2: ">16" }`

- By default questions on pages that are not routed to are assumed to be invalid and are cleared. This can be prevented by setting `derived: true` on a question.

- Questions can be optionally hidden from the check answers page of each section by setting `hidden_in_check_answers: true`. This can also take a condition.

- Questions can be set as being inferred from other answers. This is similar to derived with the difference being that derived questions can be derived from anything not just other form question answers, and inferred answers are cleared when the answers they depend on change, whereas derived questions aren’t.

- Soft validation interruption pages can be included

- For complex HTML guidance partials can be referenced

## Form definition

The Form should follow the structure:

```
SECTIONS = [
  Form::Sales::Sections::Section
].freeze

Form.new(nil, start_year, SECTIONS, form_type - "lettings" / "sales")

class Form::Sales::Sections::Section < ::Form::Section
  def initialize(id, hsh, form)
    super
    @id = [snake_case_section_name_string]
    @label = [String]
    @description = [String]
    @subsections = [Form::Sales::Subsections::Subsection.new(nil, nil, self)]
  end
end

class Form::Sales::Subsections::Subsection < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = [snake_case_subsection_name_string]
    @label = [String]
    @depends_on = [{ "question_key/method_key": "answer_value_required_for_this_subsection_to_be_shown" }]
  end

  def pages
    @pages ||= [Form::Sales::Pages::Page.new(nil, nil, self),]
  end
end

class Form::Sales::Pages::Page < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = [snake_case_page_name_string]
    @header = [String,]
    @depends_on = [{ "question_key": "answer_value_required_for_this_page_to_be_shown" }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Question.new(nil, nil, self),
    ]
  end
end

class Form::Sales::Questions::Question < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = [snake_case_question_name_string]
    @hint_text = [String,]
    @check_answer_label = [String,]
    @type = ["text" / "numeric" / "radio" / "checkbox" / "date",]
    @min = [Integer, // numeric only]
    @max = [Integer, // numeric only]
    @step = [Integer, // numeric only]
    @width = [2 / 3 / 4 / 5 / 10 / 20, // text and numeric only]
    @prefix = [String, // numeric only]
    @suffix = [String, //numeric only]
    @answer_options = { // checkbox and radio only
      "0": String,
      "1": String
    },
    @conditional_for = {
      "[snake_case_question_to_enable_1_name_string]": ["condition-that-enables"],
      "[snake_case_question_to_enable_2_name_string]": ["condition-that-enables"]
    },
    @inferred_answers = { "field_that_gets_inferred_from_current_field": { "is_that_field_inferred": true } },
    @inferred_check_answers_value = [{
      "condition": { "field_name_for_inferred_check_answers_condition": "field_value_for_inferred_check_answers_condition" },
      "value": "Inferred value that gets displayed if condition is met"
    }]
    @question_number = Integer
  end
end
```

Assumptions made by the format:

- All forms have at least 1 section

- All sections have at least 1 subsection

- All subsections have at least 1 page

- All pages have at least 1 question

- The ActiveRecord lettings log model has a field for each question name (must match). In the case of checkbox questions it must have one field for every answer option (again names must match).

- Text not required by a page/question such as a header or hint text should be passed as an empty string

- For conditionally shown questions, conditions that have been implemented and can be used are:

  - Radio question answer option selected matches one of conditional e.g.\
    `["answer-options-1-string", "answer-option-3-string"]`

  - Numeric question value matches condition e.g. [">2"], ["<7"] or ["== 6"]

- When the top level question is a radio button and the conditional question is a numeric, text or date field then the conditional question is shown inline

- When the conditional question is a radio, checkbox or select field it should be displayed on it’s own page and "depends_on" should be used rather than "conditional_for"

### Page routing

Form navigation works by stepping sequentially through every page defined in the JSON form definition for the given subsection. For every page it checks if it has "depends_on" conditions. If it does, it evaluates them to determine whether that page should be show or not.

We can also define custom `routed_to?` methods on pages for more complex routing logic.

## Form models and definition

For information about the form model and related models (section, subsection, page, question) and how these relate to each other see [form definition](/form/definition).
