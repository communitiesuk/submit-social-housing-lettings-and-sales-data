class Form::Sales::Questions::SaleDate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "saledate"
    @copy_key = "sales.setup.saledate"
    @type = "date"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 1, 2024 => 3 }.freeze
end
