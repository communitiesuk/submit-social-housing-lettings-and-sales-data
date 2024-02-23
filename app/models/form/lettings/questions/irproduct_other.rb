class Form::Lettings::Questions::IrproductOther < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "irproduct_other"
    @check_answer_label = "Product name"
    @header = "Name of rent product"
    @type = "text"
    @question_number = QUESTION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last) if form.start_date.present?
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 6 }.freeze
end
