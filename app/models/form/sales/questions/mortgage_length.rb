class Form::Sales::Questions::MortgageLength < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @id = "mortlen"
    @check_answer_label = "Length of mortgage"
    @header = "What is the length of the mortgage?"
    @type = "numeric"
    @min = 0
    @max = 60
    @step = 1
    @width = 5
    @hint_text = "You should round up to the nearest year. Value should not exceed 60 years."
    @ownershipsch = ownershipsch
    @question_number = QUESION_NUMBER_FROM_YEAR_AND_OWNERSHIP[form.start_date.year][ownershipsch] if QUESION_NUMBER_FROM_YEAR_AND_OWNERSHIP[form.start_date.year].present?
  end

  def suffix_label(log)
    " #{'year'.pluralize(log[id])}"
  end

  QUESION_NUMBER_FROM_YEAR_AND_OWNERSHIP = {
    2023 => { 1 => 93, 2 => 106, 3 => 114 },
    2024 => { 1 => 95, 2 => 108, 3 => 115 },
  }.freeze
end
