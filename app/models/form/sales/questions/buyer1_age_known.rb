class Form::Sales::Questions::Buyer1AgeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age1_known"
    @check_answer_label = "Lead buyer’s age"
    @header = "Do you know buyer 1’s age?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = "Buyer 1 is the person in the household who does the most paid work. If it’s a joint purchase and the buyers do the same amount of paid work, buyer 1 is whoever is the oldest."
    @conditional_for = {
      "age1" => [0],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "age1_known" => 0,
        },
        {
          "age1_known" => 1,
        }
      ],
    }
    @check_answers_card_number = 1
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
    "2" => { "value" => "Buyer prefers not to say" },
  }.freeze
end
