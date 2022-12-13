class Form::Sales::Questions::Person1RelationshipToBuyer1JointPurchase < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "relat3"
    @check_answer_label = "Person 1's relationship to buyer 1"
    @header = "What is person 1's relationship to buyer 1?"
    @type = "radio"
    @hint_text = ""
    @page = page
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 3
  end

  ANSWER_OPTIONS = {
    "P" => { "value" => "Partner" },
    "C" => { "value" => "Child", "hint" => "Must be eligible for child benefit, aged under 16 or under 20 if still in full-time education." },
    "X" => { "value" => "Other" },
    "R" => { "value" => "Buyer prefers not to say" },
  }.freeze
end
