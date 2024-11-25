class Form::Sales::Questions::MortgageLength < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @id = "mortlen"
    @type = "numeric"
    @min = 0
    @max = 60
    @step = 1
    @width = 5
    @ownershipsch = ownershipsch
    @question_number = QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.max_by { |k, _v| k }.last)[ownershipsch]
  end

  def suffix_label(log)
    " #{'year'.pluralize(log[id])}"
  end

  QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP = {
    2023 => { 1 => 93, 2 => 106, 3 => 114 },
    2024 => { 1 => 94, 2 => 107, 3 => 114 },
  }.freeze
end
