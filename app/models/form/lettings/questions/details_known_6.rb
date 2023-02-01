class Form::Lettings::Questions::DetailsKnown6 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "details_known_6"
    @check_answer_label = "Details known for person 6"
    @header = "Do you know details for person 6?"
    @type = "radio"
    @check_answers_card_number = 6
    @hint_text = "You must provide details for everyone in the household if you know them."
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
