class Form::Lettings::Questions::Majorrepairs < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "majorrepairs"
    @check_answer_label = "Major repairs carried out during void period"
    @header = "Were any major repairs carried out during the void period?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = "Major repairs are works that could not be reasonably carried out with a tenant living at the property. For example, structural repairs."
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "mrcdate" => [1] }
    @question_number = QUESTION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = { "1" => { "value" => "Yes" }, "0" => { "value" => "No" } }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 24 }.freeze
end
