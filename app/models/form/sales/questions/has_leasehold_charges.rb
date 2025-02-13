class Form::Sales::Questions::HasLeaseholdCharges < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @id = "has_mscharge"
    @copy_key = "sales.sale_information.leaseholdcharges.has_mscharge"
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
    @question_number = QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.max_by { |k, _v| k }.last)[ownershipsch]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP = {
    2024 => { 1 => 99, 2 => 110, 3 => 117 },
    2025 => { 1 => 88, 2 => 111 },
  }.freeze
end
