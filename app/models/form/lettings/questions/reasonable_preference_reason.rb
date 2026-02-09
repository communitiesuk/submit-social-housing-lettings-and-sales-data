class Form::Lettings::Questions::ReasonablePreferenceReason < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "reasonable_preference_reason"
    @type = "checkbox"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "rp_homeless" => { "value" => "They were homeless or about to lose their home (within 56 days)" },
    "rp_insan_unsat" => { "value" => "They were living in unsanitary, overcrowded or unsatisfactory housing" },
    "rp_medwel" => { "value" => "They needed to move due to medical and welfare reasons (including disability)" },
    "rp_hardship" => { "value" => "They needed to move to avoid hardship to themselves or others" },
    "divider" => { "value" => true },
    "rp_dontknow" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 83, 2024 => 82, 2025 => 82, 2026 => 89 }.freeze
end
