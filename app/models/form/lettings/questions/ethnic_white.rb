class Form::Lettings::Questions::EthnicWhite < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnic"
    @check_answer_label = "Lead tenant’s ethnic background"
    @header = "Which of the following best describes the lead tenant’s White background?"
    @type = "radio"
    @check_answers_card_number = 1
    @hint_text = "The lead tenant is the person in the household who does the most paid work. If several people do the same paid work, the lead tenant is whoever is the oldest."
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "English, Welsh, Northern Irish, Scottish or British" },
    "2" => { "value" => "Irish" },
    "18" => { "value" => "Gypsy or Irish Traveller" },
    "3" => { "value" => "Any other White background" },
  }.freeze
end
