class Form::Lettings::Questions::Unitletas < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "unitletas"
    @check_answer_label = "Most recent let type"
    @header = "What type was the property most recently let as?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = { "1" => { "value" => "Social rent basis" }, "2" => { "value" => "Affordable rent basis" }, "4" => { "value" => "Intermediate rent basis" }, "divider" => { "value" => true }, "3" => { "value" => "Don’t know" } }.freeze
end
