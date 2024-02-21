class Form::Lettings::Questions::Wheelchair < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "wchair"
    @check_answer_label = "Property built or adapted to wheelchair-user standards"
    @header = "Is the property built or adapted to wheelchair-user standards?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = form.start_year_after_2024? ? "This is whether someone who uses a wheelchair is able to make full use of all of the property’s rooms and facilities, including use of both inside and outside space, and entering and exiting the property." : ""
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze

  QUESION_NUMBER_FROM_YEAR = { 2023 => 21 }.freeze
end
