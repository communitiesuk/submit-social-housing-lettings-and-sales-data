class Form::Lettings::Questions::DetailsKnown4 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "details_known_4"
    @check_answer_label = "Details known for person 4"
    @header = "Do you know details for person 4?"
    @type = "radio"
    @check_answers_card_number = 4
    @hint_text = "You must provide details for everyone in the household if you know them."
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
