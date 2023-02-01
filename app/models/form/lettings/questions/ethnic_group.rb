class Form::Lettings::Questions::EthnicGroup < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnic_group"
    @check_answer_label = "Lead tenant’s ethnic group"
    @header = "What is the lead tenant’s ethnic group?"
    @type = "radio"
    @check_answers_card_number = 1
    @hint_text = "The lead tenant is the person in the household who does the most paid work. If several people do the same paid work, the lead tenant is whoever is the oldest."
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = { "0" => { "value" => "White" }, "1" => { "value" => "Mixed or Multiple ethnic groups" }, "2" => { "value" => "Asian or Asian British" }, "3" => { "value" => "Black, African, Caribbean or Black British" }, "4" => { "value" => "Arab or other ethnic group" }, "divider" => { "value" => true }, "17" => { "value" => "Tenant prefers not to say" } }.freeze
end
