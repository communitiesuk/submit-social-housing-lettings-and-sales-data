class Form::Sales::Questions::ExtraBorrowing < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @id = "extrabor"
    @check_answer_label = "Any other borrowing?"
    @header = "Does this include any extra borrowing?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = ""
    @ownershipsch = ownershipsch
    @question_number = QUESION_NUMBER_FROM_YEAR_AND_OWNERSHIP[form.start_date.year][ownershipsch] if QUESION_NUMBER_FROM_YEAR_AND_OWNERSHIP[form.start_date.year].present?
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don't know" },
  }.freeze

  QUESION_NUMBER_FROM_YEAR_AND_OWNERSHIP = {
    2023 => { 1 => 94, 2 => 107, 3 => 115 },
    2024 => { 1 => 96, 2 => 109, 3 => 116 },
  }.freeze
end
