class Form::Sales::Questions::HasLeaseholdCharges < ::Form::Question
  def initialize(id, hsh, page, ownershipsch:)
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
    @ownershipsch = ownershipsch
    @copy_key = "sales.sale_information.leaseholdcharges.has_mscharge"
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR_AND_SECTION, value_key: form.start_year_2026_or_later? ? subsection.id : ownershipsch)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR_AND_SECTION = {
    2024 => { 1 => 99, 2 => 110, 3 => 117 },
    2025 => { 2 => 111 },
    2026 => 121,
  }.freeze
end
