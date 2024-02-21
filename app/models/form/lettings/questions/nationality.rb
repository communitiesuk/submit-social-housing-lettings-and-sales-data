class Form::Lettings::Questions::Nationality < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "national"
    @check_answer_label = "Lead tenant’s nationality"
    @header = "What is the nationality of the lead tenant?"
    @type = "radio"
    @check_answers_card_number = 1
    @hint_text = "The lead tenant is the person in the household who does the most paid work. If several people do the same paid work, the lead tenant is whoever is the oldest."
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "18" => { "value" => "United Kingdom" },
    "17" => { "value" => "Republic of Ireland" },
    "19" => { "value" => "European Economic Area (EEA) country, excluding Ireland" },
    "20" => { "value" => "Afghanistan" },
    "21" => { "value" => "Ukraine" },
    "12" => { "value" => "Other" },
    "divider" => true,
    "13" => { "value" => "Tenant prefers not to say" },
  }.freeze

  QUESION_NUMBER_FROM_YEAR = { 2023 => 36, 2024 => 35 }.freeze
end
