class Form::Lettings::Questions::DetailsKnown < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @id = "details_known_#{person_index}"
    @check_answer_label = "Details known for person #{person_index}"
    @header = "Do you know details for person #{person_index}?"
    @type = "radio"
    @check_answers_card_number = person_index
    @hint_text = "You must provide details for everyone in the household if you know them."
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
