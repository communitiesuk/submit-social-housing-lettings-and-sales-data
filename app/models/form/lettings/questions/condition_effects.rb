class Form::Lettings::Questions::ConditionEffects < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "condition_effects"
    @type = "checkbox"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "illness_type_4" => {
      "value" => "Dexterity",
      "hint" => "For example, lifting and carrying objects or using a keyboard.",
    },
    "illness_type_5" => { "value" => "Learning or understanding or concentrating" },
    "illness_type_2" => { "value" => "Hearing", "hint" => "For example, deafness or partial hearing." },
    "illness_type_6" => { "value" => "Memory" },
    "illness_type_7" => { "value" => "Mental health", "hint" => "For example, depression or anxiety." },
    "illness_type_3" => { "value" => "Mobility", "hint" => "For example, walking short distances or climbing stairs." },
    "illness_type_9" => {
      "value" => "Socially or behaviourally",
      "hint" => "For example, associated with autism spectrum disorder (ASD) which includes Asperger’s or attention deficit hyperactivity disorder (ADHD).",
    },
    "illness_type_8" => { "value" => "Stamina or breathing or fatigue" },
    "illness_type_1" => { "value" => "Vision", "hint" => "For example, blindness or partial sight." },
    "illness_type_10" => { "value" => "Other" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 74, 2024 => 73, 2025 => 73, 2026 => 72 }.freeze
end
