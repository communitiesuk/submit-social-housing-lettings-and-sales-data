class Form::Sales::Questions::PurchaserCode < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "purchid"
    @check_answer_label = "Purchaser code"
    @header = "What is the purchaser code?"
    @hint_text = "This is how you usually refer to the purchaser on your own systems."
    @type = "text"
    @width = 10
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 2, 2024 => 4 }.freeze
end
