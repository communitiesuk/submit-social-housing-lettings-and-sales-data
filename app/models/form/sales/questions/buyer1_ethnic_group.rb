class Form::Sales::Questions::Buyer1EthnicGroup < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnic_group"
    @check_answer_label = "Buyer 1’s ethnic group"
    @header = "What is buyer 1’s ethnic group?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = "Buyer 1 is the person in the household who does the most paid work. If it’s a joint purchase and the buyers do the same amount of paid work, buyer 1 is whoever is the oldest."
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "White" },
    "1" => { "value" => "Mixed or Multiple ethnic groups" },
    "2" => { "value" => "Asian or Asian British" },
    "3" => { "value" => "Black, African, Caribbean or Black British" },
    "4" => { "value" => "Arab or other ethnic group" },
    "divider" => { "value" => true },
    "17" => { "value" => "Buyer 1 prefers not to say" },
  }.freeze
end
