class Form::Lettings::Questions::Relat8 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "relat8"
    @check_answer_label = "Person 8’s relationship to the lead tenant"
    @header = "What is person 8’s relationship to the lead tenant?"
    @type = "radio"
    @check_answers_card_number = 8
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = { "P" => { "value" => "Partner" }, "C" => { "value" => "Child", "hint" => "Must be eligible for child benefit, aged under 16 or under 20 if still in full-time education." }, "X" => { "value" => "Other" }, "divider" => { "value" => true }, "R" => { "value" => "Person prefers not to say" } }.freeze
end
