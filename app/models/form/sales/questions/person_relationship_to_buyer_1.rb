class Form::Sales::Questions::PersonRelationshipToBuyer1 < ::Form::Sales::Questions::Person
  def initialize(id, hsh, page, person_index:)
    super
    @check_answer_label = "Person #{person_display_number}’s relationship to Buyer 1"
    @header = "What is Person #{person_display_number}’s relationship to Buyer 1?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = person_index
  end

  ANSWER_OPTIONS = {
    "P" => { "value" => "Partner" },
    "C" => { "value" => "Child", "hint" => "Must be eligible for child benefit, aged under 16 or under 20 if still in full-time education." },
    "X" => { "value" => "Other" },
    "R" => { "value" => "Person prefers not to say" },
  }.freeze
end
