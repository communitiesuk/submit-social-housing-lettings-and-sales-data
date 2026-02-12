class Form::Lettings::Questions::LeadTenantSexRegisteredAtBirth < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "sexrab1"
    @type = "radio"
    @check_answers_card_number = 1
    @answer_options = ANSWER_OPTIONS
    @inferred_check_answers_value = [{
      "condition" => {
        @id => "R",
      },
      "value" => "Prefers not to say",
    }]
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "F" => { "value" => "Female" },
    "M" => { "value" => "Male" },
    "divider" => { "value" => true },
    "R" => { "value" => "Lead tenant prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2026 => 31 }.freeze
end
