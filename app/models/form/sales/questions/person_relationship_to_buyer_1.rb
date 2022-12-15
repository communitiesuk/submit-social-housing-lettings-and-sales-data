class Form::Sales::Questions::PersonRelationshipToBuyer1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @check_answer_label = "Person #{person_display_number(PERSON_INDEX)}’s relationship to buyer 1"
    @header = "What is Person #{person_display_number(PERSON_INDEX)}’s relationship to buyer 1?"
    @type = "radio"
    @hint_text = ""
    @page = page
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = person_database_number(PERSON_INDEX)
  end

  ANSWER_OPTIONS = {
    "P" => { "value" => "Partner" },
    "C" => { "value" => "Child", "hint" => "Must be eligible for child benefit, aged under 16 or under 20 if still in full-time education." },
    "X" => { "value" => "Other" },
    "R" => { "value" => "Person prefers not to say" },
  }.freeze

  PERSON_INDEX = {
    "relat2" => 2,
    "relat3" => 3,
    "relat4" => 4,
    "relat5" => 5,
    "relat6" => 6,
  }.freeze
end
