class Form::Lettings::Questions::Startertenancy < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "startertenancy"
    @check_answer_label = "Is this a starter or introductory tenancy?"
    @header = "Is this a starter tenancy?"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = { "1" => { "value" => "Yes" }, "2" => { "value" => "No" } }.freeze

  def hint_text
    if form.start_year_after_2024?
      "If the tenancy has an ‘introductory period’ answer ‘yes’.<br><br>
       You should submit a CORE log at the beginning of the starter tenancy or introductory period, with the best information you have at the time. You do not need to submit a log when a tenant later rolls onto the main tenancy."
    else
      "This is also known as an ‘introductory period’."
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 26 }.freeze
end
