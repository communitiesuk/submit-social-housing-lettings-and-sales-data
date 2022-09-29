class Form::Sales::Questions::Buyer2RelationshipToBuyer1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "relat2"
    @check_answer_label = "Buyer 2's relationship to buyer 1"
    @header = "What is buyer 2's relationship to buyer 1?"
    @type = "radio"
    @hint_text = ""
    @page = page
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "otherrelat2" => %w[X],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "relat2" => "X",
        },
      ],
    }
  end

  ANSWER_OPTIONS = {
    "P" => { "value" => "Parent" },
    "C" => { "value" => "Child", "hint" => "Must be eligible for child benefit, aged under 16 or under 20 if still in full-time education." },
    "X" => { "value" => "Other" },
    "R" => { "value" => "Buyer prefers not to say" },
  }.freeze
end
