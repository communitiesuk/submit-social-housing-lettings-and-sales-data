class Form::Lettings::Questions::WorkingSituationIllnessCheck < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @id = "working_situation_illness_check"
    @copy_key = page.copy_key
    @type = "interruption_screen"
    @check_answers_card_number = person_index
    @hidden_in_check_answers = { "depends_on" => [{ "working_situation_illness_check" => 0 }, { "working_situation_illness_check" => 1 }] }
  end
end
