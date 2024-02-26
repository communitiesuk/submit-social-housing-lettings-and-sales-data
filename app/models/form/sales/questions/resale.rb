class Form::Sales::Questions::Resale < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "resale"
    @check_answer_label = "Is this a resale?"
    @header = "Is this a resale?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = "If the social landlord has previously sold the property to another buyer and is now reselling the property, select 'yes'. If this is the first time the property has been sold, select 'no'."
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 80, 2024 => 82 }.freeze
end
