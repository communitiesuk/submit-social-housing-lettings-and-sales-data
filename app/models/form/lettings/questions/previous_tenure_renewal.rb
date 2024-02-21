class Form::Lettings::Questions::PreviousTenureRenewal < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "prevten"
    @check_answer_label = "Where was the household immediately before this letting?"
    @header = "Where was the household immediately before this letting?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "34" => { "value" => "Specialist retirement housing" },
    "36" => { "value" => "Sheltered housing for adults aged under 55 years" },
    "35" => { "value" => "Extra care housing" },
    "6" => { "value" => "Other supported housing" },
  }.freeze

  QUESION_NUMBER_FROM_YEAR = { 2023 => 78, 2024 => 77 }.freeze
end
