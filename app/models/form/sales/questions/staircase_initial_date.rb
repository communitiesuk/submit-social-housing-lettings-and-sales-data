class Form::Sales::Questions::StaircaseInitialDate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "initialpurchase"
    @copy_key = "sales.sale_information.stairprevious.initialpurchase"
    @type = "date"
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2025 => 96, 2026 => 104 }.freeze
end
