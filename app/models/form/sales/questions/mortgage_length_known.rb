class Form::Sales::Questions::MortgageLengthKnown < ::Form::Question
  def initialize(id, hsh, page, ownershipsch:)
    super(id, hsh, page)
    @id = "mortlen_known"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "mortlen" => [0] }
    @hidden_in_check_answers = {
      "depends_on" => [
        { "mortlen_known" => 0 },
      ],
    }
    @question_number = QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.max_by { |k, _v| k }.last)[ownershipsch]
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze

  QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP = {
    2026 => { 1 => 84, 2 => 108 },
  }.freeze
end
