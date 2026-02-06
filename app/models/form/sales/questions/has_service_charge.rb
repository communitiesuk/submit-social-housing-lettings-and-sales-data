class Form::Sales::Questions::HasServiceCharge < ::Form::Question
  def initialize(id, hsh, subsection, staircasing:)
    super(id, hsh, subsection)
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
    @question_number = question_number_from_year[form.start_date.year] || question_number_from_year[question_number_from_year.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No" },
  }.freeze

  def question_number_from_year
    if @staircasing
      { 2026 => 0 }.freeze
    else
      { 2025 => 88 }.freeze
    end
  end
end
