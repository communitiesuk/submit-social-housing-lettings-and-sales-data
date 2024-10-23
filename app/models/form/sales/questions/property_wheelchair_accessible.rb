class Form::Sales::Questions::PropertyWheelchairAccessible < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "wchair"
    @copy_key = "sales.property_information.wchair"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @hint_text = form.start_year_after_2024? ? "This is whether someone who uses a wheelchair is able to make full use of all of the property’s rooms and facilities, including use of both inside and outside space, and entering and exiting the property." : nil
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don't know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 17, 2024 => 21 }.freeze
end
