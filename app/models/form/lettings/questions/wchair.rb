class Form::Lettings::Questions::Wchair < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "wchair"
    @check_answer_label = "Property built or adapted to wheelchair-user standards"
    @header = "Is the property built or adapted to wheelchair-user standards?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = { "1" => { "value" => "Yes" }, "2" => { "value" => "No" } }.freeze
end
