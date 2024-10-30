class Form::Lettings::Questions::TenancyLengthIntermediateRent < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "tenancylength"
    @copy_key = "lettings.tenancy_information.tenancylength.#{page.id}"
    @type = "numeric"
    @width = 2
    @check_answers_card_number = 0
    @max = 150
    @min = 0
    @step = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 28 }.freeze
end
