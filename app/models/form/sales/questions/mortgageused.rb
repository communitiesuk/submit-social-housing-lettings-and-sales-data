class Form::Sales::Questions::Mortgageused < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @id = "mortgageused"
    @check_answer_label = "Mortgage used"
    @header = "Was a mortgage used for the purchase of this property?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @ownershipsch = ownershipsch
    @question_number = QUESION_NUMBER_FROM_YEAR_AND_OWNERSHIP.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR_AND_OWNERSHIP.max_by { |k, _v| k }.last)[ownershipsch]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don’t know" },
  }.freeze

  def displayed_answer_options(log, _user = nil)
    if log.stairowned == 100 || @ownershipsch == 3
      ANSWER_OPTIONS
    else
      {
        "1" => { "value" => "Yes" },
        "2" => { "value" => "No" },
      }
    end
  end

  QUESION_NUMBER_FROM_YEAR_AND_OWNERSHIP = {
    2023 => { 1 => 90, 2 => 103, 3 => 111 },
    2024 => { 1 => 92, 2 => 105, 3 => 113 },
  }.freeze
end
