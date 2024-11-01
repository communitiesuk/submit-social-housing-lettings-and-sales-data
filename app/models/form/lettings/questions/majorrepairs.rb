class Form::Lettings::Questions::Majorrepairs < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "majorrepairs"
    @copy_key = "lettings.property_information.property_major_repairs.majorrepairs"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "mrcdate" => [1] }
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = { "1" => { "value" => "Yes" }, "0" => { "value" => "No" } }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 24 }.freeze
end
