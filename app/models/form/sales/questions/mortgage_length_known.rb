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
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR_AND_SECTION, value_key: form.start_year_2026_or_later? ? subsection.id : ownershipsch)
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze

  QUESTION_NUMBER_FROM_YEAR_AND_SECTION = {
    2026 => { "shared_ownership_initial_purchase" => 92, "discounted_ownership_scheme" => 118 },
  }.freeze
end
