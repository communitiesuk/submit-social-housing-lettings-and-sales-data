class Form::Lettings::Questions::Mrcdate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "mrcdate"
    @copy_key = "lettings.property_information.property_major_repairs.mrcdate"
    @type = "date"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 24 }.freeze
end
