class Form::Lettings::Questions::Ppcodenk < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ppcodenk"
    @check_answer_label = ""
    @header = "Do you know the postcode of the household’s last settled accommodation?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = form.start_year_after_2024? ? "This is the tenant’s last long-standing home. It is where the tenant was living before any period in temporary accommodation, sleeping rough or otherwise homeless." : "This is also known as the household’s ‘last settled home’."
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "ppostcode_full" => [0] }
    @hidden_in_check_answers = { "depends_on" => [{ "ppcodenk" => 0 }, { "ppcodenk" => 1 }] }
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 80, 2024 => 79 }.freeze
end
