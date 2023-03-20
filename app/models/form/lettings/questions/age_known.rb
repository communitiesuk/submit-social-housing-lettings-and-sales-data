class Form::Lettings::Questions::AgeKnown < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @id = "age#{person_index}_known"
    @check_answer_label = ""
    @header = "Do you know person #{person_index}’s age?"
    @type = "radio"
    @check_answers_card_number = person_index
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "age#{person_index}" => [0] }
    @hidden_in_check_answers = {
      "depends_on" => [
        { "age#{person_index}_known" => 0 },
        { "age#{person_index}_known" => 1 },
      ],
    }
    @question_number = 31 + (4 * person_index)
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
