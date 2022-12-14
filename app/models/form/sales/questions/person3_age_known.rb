class Form::Sales::Questions::Person3AgeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @check_answer_label = "Person 3’s age known?"
    @header = "Do you know person 3’s age?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = ""
    @conditional_for = hsh[:conditional_for]
    @hidden_in_check_answers = hsh[:hidden_in_check_answers]
    @check_answers_card_number = hsh[:check_answers_card_number]
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end
