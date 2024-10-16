class Form::Sales::Questions::PreviousLaKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "previous_la_known"
    @check_answer_label = "Local authority of buyer 1’s last settled accommodation"
    @header = "Do you know the local authority of buyer 1’s last settled accommodation?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = "This is also known as the household’s 'last settled home'"
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "previous_la_known" => 0,
        },
        {
          "previous_la_known" => 1,
        },
      ],
    }
    @conditional_for = {
      "prevloc" => [1],
    }
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 58, 2024 => 60 }.freeze
end
