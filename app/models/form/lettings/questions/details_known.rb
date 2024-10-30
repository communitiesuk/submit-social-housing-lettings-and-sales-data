class Form::Lettings::Questions::DetailsKnown < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @id = "details_known_#{person_index}"
    @type = "radio"
    @check_answers_card_number = person_index
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
