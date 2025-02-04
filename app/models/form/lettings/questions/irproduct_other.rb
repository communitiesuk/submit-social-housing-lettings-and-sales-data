class Form::Lettings::Questions::IrproductOther < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "irproduct_other"
    @copy_key = "lettings.setup.rent_type.irproduct_other"
    @type = "text"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max] if form.start_date.present?
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 6, 2024 => 8 }.freeze
end
