class Form::Lettings::Questions::Builtype < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "builtype"
    @check_answer_label = "Type of building"
    @header = "What type of building is the property?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "2" => { "value" => "Converted from previous residential or non-residential property" },
    "1" => { "value" => "Purpose built" },
  }.freeze

  QUESION_NUMBER_FROM_YEAR = { 2023 => 20 }.freeze
end
