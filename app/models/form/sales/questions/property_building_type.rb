class Form::Sales::Questions::PropertyBuildingType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "builtype"
    @copy_key = "sales.property_information.builtype"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Purpose built" },
    "2" => { "value" => "Converted from previous residential or non-residential property" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 13, 2024 => 20, 2025 => 18, 2026 => 19 }.freeze
end
