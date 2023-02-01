class Form::Lettings::Questions::Hbrentshortfall < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hbrentshortfall"
    @check_answer_label = "Any outstanding amount for basic rent and charges"
    @header = "After the household has received any housing-related benefits, will they still need to pay for rent and charges?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = "Also known as the ‘outstanding amount’."
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = { "1" => { "value" => "Yes" }, "2" => { "value" => "No" }, "3" => { "value" => "Don’t know" } }.freeze
end
