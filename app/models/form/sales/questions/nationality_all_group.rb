class Form::Sales::Questions::NationalityAllGroup < ::Form::Question
  def initialize(id, hsh, page, buyer_index)
    super(id, hsh, page)
    @check_answer_label = "Buyer #{buyer_index}’s nationality"
    @header = "What is buyer #{buyer_index}’s nationality?"
    @type = "radio"
    @hint_text = "If buyer #{buyer_index} is a dual national of the United Kingdom and another country, enter United Kingdom. If they are a dual national of two other countries, the buyer should decide which country to enter."
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = buyer_index
    @conditional_for = buyer_index == 1 ? { "nationality_all" => [12] } : { "nationality_all_buyer2" => [12] }
    @hidden_in_check_answers = { "depends_on" => [{ id => 12 }] }
    @buyer_index = buyer_index
    @question_number = question_number
  end

  ANSWER_OPTIONS = {
    "826" => { "value" => "United Kingdom" },
    "12" => { "value" => "Other" },
    "0" => { "value" => "Buyer prefers not to say" },
  }.freeze

  def question_number
    if form.start_date.year == 2023
      @buyer_index == 1 ? 24 : 32
    else
      @buyer_index == 1 ? 26 : 34
    end
  end
end
