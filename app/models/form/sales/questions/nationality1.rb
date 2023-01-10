class Form::Sales::Questions::Nationality1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "national"
    @check_answer_label = "Buyer 1’s nationality"
    @header = "What is buyer 1’s nationality?"
    @type = "radio"
    @hint_text = "Buyer 1 is the person in the household who does the most paid work. If it’s a joint purchase and the buyers do the same amount of paid work, buyer 1 is whoever is the oldest."
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "othernational" => [12],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "national" => 12,
        },
      ],
    }
    @check_answers_card_number = 1
  end

  ANSWER_OPTIONS = {
    "18" => { "value" => "United Kingdom" },
    "17" => { "value" => "Republic of Ireland" },
    "19" => { "value" => "European Economic Area (EEA), excluding ROI" },
    "12" => { "value" => "Other" },
    "13" => { "value" => "Buyer prefers not to say" },
  }.freeze
end
