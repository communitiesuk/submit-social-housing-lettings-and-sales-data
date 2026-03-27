class Form::Sales::Questions::Buyer1WorkingSituation < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ecstat1"
    @type = "radio"
    @answer_options = answer_options
    @check_answers_card_number = 1
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  def answer_options
    if form.start_year_2025_or_later?
      {
        "1" => { "value" => "Full-time – 30 hours or more per week" },
        "2" => { "value" => "Part-time – Less than 30 hours per week" },
        "3" => { "value" => "In government training into work" },
        "4" => { "value" => "Jobseeker" },
        "5" => { "value" => "Retired" },
        "6" => { "value" => "Not seeking work" },
        "7" => { "value" => "Full-time student" },
        "8" => { "value" => "Unable to work because of long-term sickness or disability" },
        "0" => { "value" => "Other" },
        "10" => { "value" => "Buyer prefers not to say" },
      }.freeze
    else
      {
        "1" => { "value" => "Full-time - 30 hours or more" },
        "2" => { "value" => "Part-time - Less than 30 hours" },
        "3" => { "value" => "In government training into work" },
        "4" => { "value" => "Jobseeker" },
        "6" => { "value" => "Not seeking work" },
        "8" => { "value" => "Unable to work due to long term sick or disability" },
        "5" => { "value" => "Retired" },
        "0" => { "value" => "Other" },
        "10" => { "value" => "Buyer prefers not to say" },
        "7" => { "value" => "Full-time student" },
      }.freeze
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 25, 2024 => 27, 2025 => 25, 2026 => 27 }.freeze
  def label_from_value(value, _log = nil, _user = nil)
    return unless value

    return "Prefers not to say" if value == "10"

    super
  end
end
