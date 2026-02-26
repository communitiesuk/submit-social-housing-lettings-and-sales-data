class Form::Lettings::Questions::Majorrepairs < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "majorrepairs"
    @copy_key = "lettings.property_information.property_major_repairs.majorrepairs"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "mrcdate" => [1] }
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = { "1" => { "value" => "Yes" }, "0" => { "value" => "No" } }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 24, 2024 => 24, 2025 => 24, 2026 => 23 }.freeze
end
