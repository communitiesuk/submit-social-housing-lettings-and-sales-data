class Form::Lettings::Questions::Period < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "period"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "2" => { "value" => "Every 2 weeks" },
    "3" => { "value" => "Every 4 weeks" },
    "4" => { "value" => "Every calendar month" },
    "9" => { "value" => "Weekly for 46 weeks" },
    "8" => { "value" => "Weekly for 47 weeks" },
    "7" => { "value" => "Weekly for 48 weeks" },
    "6" => { "value" => "Weekly for 49 weeks" },
    "5" => { "value" => "Weekly for 50 weeks" },
    "11" => { "value" => "Weekly for 51 weeks" },
    "1" => { "value" => "Weekly for 52 weeks" },
    "10" => { "value" => "Weekly for 53 weeks" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 92, 2024 => 91, 2025 => 91, 2026 => 98 }.freeze

  def displayed_answer_options(log, _user)
    return ANSWER_OPTIONS if log.managing_organisation.nil?

    available_rent_periods = log.managing_organisation.rent_periods

    ANSWER_OPTIONS.select { |key, _| available_rent_periods.include?(key.to_i) }
  end
end
