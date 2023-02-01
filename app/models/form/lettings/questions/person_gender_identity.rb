class Form::Lettings::Questions::PersonGenderIdentity < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @id = "sex#{person_index}"
    @check_answer_label = "Person #{person_index}’s gender identity"
    @header = "Which of these best describes person #{person_index}’s gender identity?"
    @type = "radio"
    @check_answers_card_number = person_index
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = { "F" => { "value" => "Female" }, "M" => { "value" => "Male" }, "X" => { "value" => "Non-binary" }, "divider" => { "value" => true }, "R" => { "value" => "Person prefers not to say" } }.freeze
end
