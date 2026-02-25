class Form::Lettings::Questions::Builtype < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "builtype"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "2" => { "value" => "Converted from previous residential or non-residential property" },
    "1" => { "value" => "Purpose built" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 20, 2024 => 20, 2025 => 20 }.freeze
end
