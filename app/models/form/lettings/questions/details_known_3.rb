class Form::Lettings::Questions::DetailsKnown3 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "details_known_3"
    @check_answer_label = "Details known for person 3"
    @header = "Do you know details for person 3?"
    @type = "radio"
    @check_answers_card_number = 3
    @hint_text = "You must provide details for everyone in the household if you know them."
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
