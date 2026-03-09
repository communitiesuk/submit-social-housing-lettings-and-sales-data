class Form::Sales::Questions::LivingBeforePurchase < ::Form::Question
  def initialize(id, hsh, page, ownershipsch:, joint_purchase:)
    super(id, hsh, page)
    @id = "proplen_asked"
    @copy_key = "sales.sale_information.living_before_purchase.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}.proplen_asked"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "proplen" => [0],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "proplen_asked" => 0,
        },
      ],
    }
    @ownershipsch = ownershipsch
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR_AND_SECTION, value_key: form.start_year_2026_or_later? ? subsection.id : ownershipsch)
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR_AND_SECTION = {
    2023 => { 1 => 75, 2 => 99 },
    2024 => { 1 => 77, 2 => 100 },
    2025 => { 1 => 75, 2 => 102 },
    2026 => { "shared_ownership_initial_purchase" => 83, "discounted_ownership_scheme" => 114 },
  }.freeze
end
