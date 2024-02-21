class Form::Lettings::Questions::PreviousLaKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "previous_la_known"
    @check_answer_label = "Do you know the local authority of the household’s last settled accommodation?"
    @header = "Do you know the local authority of the household’s last settled accommodation?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = form.start_year_after_2024? ? "This is the tenant’s last long-standing home. It is where the tenant was living before any period in temporary accommodation, sleeping rough or otherwise homeless." : "This is also known as the household’s ‘last settled home’."
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "prevloc" => [1] }
    @hidden_in_check_answers = { "depends_on" => [{ "previous_la_known" => 0 }, { "previous_la_known" => 1 }] }
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end

  ANSWER_OPTIONS = { "1" => { "value" => "Yes" }, "0" => { "value" => "No" } }.freeze

  QUESION_NUMBER_FROM_YEAR = { 2023 => 81, 2024 => 80 }.freeze
end
