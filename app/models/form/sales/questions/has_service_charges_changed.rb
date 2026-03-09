class Form::Sales::Questions::HasServiceChargesChanged < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hasservicechargeschanged"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "newservicecharges" => [1],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "hasservicechargeschanged" => 1,
        },
      ],
    }
    @copy_key = "sales.sale_information.servicecharges_changed.has_service_charges_changed"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2026 => 113 }.freeze
end
