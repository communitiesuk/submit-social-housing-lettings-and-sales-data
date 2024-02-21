class Form::Sales::Questions::Buyer1Nationality < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "national"
    @check_answer_label = "Buyer 1’s nationality"
    @header = "What is buyer 1’s nationality?"
    @type = "radio"
    @hint_text = "Buyer 1 is the person in the household who does the most paid work. If it’s a joint purchase and the buyers do the same amount of paid work, buyer 1 is whoever is the oldest."
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 1
    @inferred_check_answers_value = [{
      "condition" => {
        "national" => 13,
      },
      "value" => "Prefers not to say",
    }]
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "18" => { "value" => "United Kingdom" },
    "17" => { "value" => "Republic of Ireland" },
    "19" => { "value" => "European Economic Area (EEA), excluding ROI" },
    "12" => { "value" => "Other" },
    "13" => { "value" => "Buyer prefers not to say" },
  }.freeze

  QUESION_NUMBER_FROM_YEAR = { 2023 => 24, 2024 => 26 }.freeze
end
