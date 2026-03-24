---
parent: Form definition
grand_parent: Generating forms
nav_order: 4
---

# Question

_Updated for 2026._

Questions are under the page level of the form definition.

An example question might look something like this:

```ruby
class Form::Sales::Questions::PreviousPostcodeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ppcodenk"
    @copy_key = "sales.household_situation.last_accommodation.ppcodenk"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "ppostcode_full" => [0],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "ppcodenk" => 0,
        },
        {
          "ppcodenk" => 1,
        },
      ],
    }
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 57, 2024 => 59, 2025 => 57 }.freeze
end
```

## Useful Properties

<dl>
<dt>id</dt>
<dd>The name of the field. This should correspond to a column in the database. In the example, the id is 'ppcodenk'.</dd>

<dt>copy_key</dt>
<dd>This specifies copy from <code>config/locales/forms/...</code> that should be associated with the question. Not normally needed, will be inferred as <code>#{form.type}.#{subsection.copy_key}.#{id}</code>.</dd>

<dt>type</dt>
<dd>Determines what type of question is rendered on the page. In the example, the question is a Radio Form so the <code>app/views/form/_radio_question.html.erb</code> partial will be rendered on the page when this question is displayed to the user</dd>

<dt>answer_options</dt>
<dd>Some types of question offer multiple options to pick from, which can be defined here. In the example, there are two options. The option that will be rendered with the label 'Yes' has the underlying value 0. The option with the label 'No' has the underlying value 1.</dd>

<dt>conditional_for</dt>
<dd>Allows for additional questions to be rendered on the page if a certain value is chosen for the current question. In the example, if the value of this question is 0 (the 'Yes' option is selected), then the question with id 'ppostcode_full' will be rendered beneath the selected option.<br/>If the user has JavaScript enabled then this realtime conditional display is handled by the <code>app/frontend/controllers/conditional_question_controller.js</code> file.</dd>

<dt>hidden_in_check_answers</dt>
<dd>
  Allows us to hide the question on the 'check your answers' page. You only need to provide this if you want to set it to true in order to hide the value for some reason e.g. it's one of two questions appearing on a page and the other question is displayed on the check answers page.
  <br/>
  If <code>depends_on</code> is supplied, then whether this question is hidden can be made conditional on the answers provided to any question. In the example, the question is hidden if 'ppcodenk' (this question) has value 0 or 1. (As these are the only two possible answers, the question will always be hidden.)
</dd>

<dt>question_number</dt>
<dd>
  Determines which number gets rendered next to the question text on the question page and in the 'check your answers' page.
  <br/>
  The convention that we use for the question number is that the hash should contain all years explicitly, even if it doesn't change between years. When building a new year's forms we should add the question number for the new year to all questions. See the `add_new_year_to_questions` rake.
</dd>

<dt>disable_clearing_if_not_routed_or_dynamic_answer_options</dt>
<dd>
  Questions that are not routed to will be cleared. Setting this to true will prevent this from happening. Normally can be replaced with implementing <code>derived?</code>.
</dd>

<dt>check_answers_card_number</dt>
<dd>
  Is used only for the household characteristics section as each person gets their own card on the CYA page. If you're looking to add a custom CYA card somewhere else in the form, see <code>check_answers_card_title</code>
</dd>
</dl>

Another example shows us some fields that are used when we want to infer the answers to one question based on a user's answers to another question. This can allow the user to have to answer fewer questions, lowering their total number of clicks.

```ruby
class Form::Sales::Questions::PostcodeForFullAddress < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "postcode_full"
    @inferred_check_answers_value = [{
      "condition" => {
        "pcodenk" => 1,
      },
      "value" => "Not known",
    }]
    @inferred_answers = {
      "la" => {
        "is_la_inferred" => true,
      },
    }
    # Other fields omitted for brevity
  end
end
```

<dl>
<dt>inferred_check_answers_value</dt>
<dd>Determines what gets shown on the 'check your answers' page if we infer the answer to this question. In the example, if the question 'pcodenk' has value 1 (indicating that the postcode is not known), then the answer shown for this question will be 'Not known'.</dd>

<dt>inferred_answers</dt>
<dd>Determines any questions whose answers can be inferred based on the answer to this question. In the example, the 'la' question (Local Authority) can be inferred from the Postcode. We set a property 'is_la_inferred' on the log to record this inferrance.</dd>
</dl>

## Useful methods

<dl>
<dt>derived?</dt>
<dd>This is function that should return true if the question is to be derived, such as where it's answer can be inferred based on another question. Setting this to true will cause the question to not be shown in CYA. The user will still be shown the question. This method is very similar to a depends_on method, but a depends_on block is used to always infer an answer of "". derived? is reliant on other code setting the answer, such as <code>set_derived_fields!</code></dd>

<dt>get_extra_check_answer_value</dt>
<dd>Used for putting extra lines below the main answer in the CYA page. Used on the address search to show the full address below the UPRN</dd>

<dt>label_from_value</dt>
<dd>Used for custom labels that differ from the main site. Normally will use the labels on the page, Useful for instance changing "No, enter xyz" to just "No".</dd>

<dt>skip_question_in_form_flow?</dt>
<dd>Similar to derived, but the user is still able to go back and edit the question later. Will not cause question to be hidden from CYA.</dd>
</dl>

## Question visibility

There are broadly 3 reasons to hide a question. Here's how to handle them.

1. The question should not be asked, answer should be derived as nil and user should not be able to change this. If so, set up a `depends_on` on the page.
2. The question should not be asked, answer should be derived as some value and user should not be able to change this. If so, set up a `depends_on` on the page and set up a `derived?`. Use a method like `set_derived_fields!` to set the answer.
3. The question should not be asked, answer should be derived as some value and user should be able to change this. If so, set up a `skip_question_in_form_flow?` method.
