class Form::Lettings::Questions::WorkingSituation1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ecstat1"
    @check_answer_label = "Lead tenant’s working situation"
    @header = "Which of these best describes the lead tenant’s working situation?"
    @type = "radio"
    @check_answers_card_number = 1
    @hint_text = form.start_year_after_2024? ? "" : "The lead tenant is the person in the household who does the most paid work. If several people do the same paid work, the lead tenant is whoever is the oldest."
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Full-time – 30 hours or more" },
    "2" => { "value" => "Part-time – Less than 30 hours" },
    "7" => { "value" => "Full-time student" },
    "3" => { "value" => "In government training into work" },
    "4" => { "value" => "Jobseeker" },
    "6" => { "value" => "Not seeking work" },
    "8" => { "value" => "Unable to work because of long term sick or disability" },
    "5" => { "value" => "Retired" },
    "0" => { "value" => "Other" },
    "divider" => { "value" => true },
    "10" => { "value" => "Tenant prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 37, 2024 => 36 }.freeze
end
