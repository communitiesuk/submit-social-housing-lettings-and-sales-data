class Form::Sales::Questions::NationalityAllGroup < ::Form::Question
  def initialize(id, hsh, page, buyer_index)
    super(id, hsh, page)
    @check_answer_label = "Buyer #{buyer_index}’s nationality"
    @header = "What is buyer #{buyer_index}’s nationality?"
    @type = "radio"
    @hint_text = buyer_index == 1 ? "Buyer 1 is the person in the household who does the most paid work. If it’s a joint purchase and the buyers do the same amount of paid work, buyer 1 is whoever is the oldest." : ""
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = buyer_index
    @question_number = buyer_index == 1 ? 24 : 32
    @conditional_for = buyer_index == 1 ? { "nationality_all" => [12] } : { "nationality_all_buyer2" => [12] }
    @hidden_in_check_answers = { "depends_on" => [{ id => 12 }] }
  end

  ANSWER_OPTIONS = {
    "826" => { "value" => "United Kingdom" },
    "12" => { "value" => "Other" },
    "13" => { "value" => "Buyer prefers not to say" },
  }.freeze
end
