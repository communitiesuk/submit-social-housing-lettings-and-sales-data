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
    @question_number = QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.max_by { |k, _v| k }.last)[ownershipsch]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don't know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP = {
    2023 => { 1 => 94, 2 => 107, 3 => 115 },
    2024 => { 1 => 96, 2 => 109, 3 => 116 },
  }.freeze
end
