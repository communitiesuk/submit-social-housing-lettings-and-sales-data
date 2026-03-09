class Form::Sales::Questions::HasServiceCharge < ::Form::Question
  def initialize(id, hsh, page, staircasing:)
    super(id, hsh, page)
    @id = "has_mscharge"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "mscharge" => [1],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "has_mscharge" => 1,
        },
      ],
    }
    @copy_key = "sales.sale_information.servicecharges.has_servicecharge"
    @staircasing = staircasing
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR_AND_SECTION, value_key: subsection.id)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR_AND_SECTION = {
    2025 => 88,
    2026 => { "shared_ownership_initial_purchase" => 88, "shared_ownership_staircasing_transaction" => 88 },
  }
end
