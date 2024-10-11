class Form::Sales::Questions::PropertyBuildingType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "builtype"
    @copy_key = "sales.property.builtype"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Purpose built" },
    "2" => { "value" => "Converted from previous residential or non-residential property" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 13, 2024 => 20 }.freeze
end
