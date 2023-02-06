class Form::Lettings::Questions::HousingneedsOther < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "housingneeds_other"
    @check_answer_label = "Other disabled access needs"
    @header = "Do they have any other access needs?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = { "1" => { "value" => "Yes" }, "0" => { "value" => "No" } }.freeze
end
