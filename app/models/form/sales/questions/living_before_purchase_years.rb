class Form::Sales::Questions::LivingBeforePurchaseYears < ::Form::Question
  def initialize(id, hsh, page, ownershipsch:, joint_purchase:)
    super(id, hsh, page)
    @id = "proplen"
    @copy_key = "sales.sale_information.living_before_purchase.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}.proplen"
    @type = "numeric"
    @min = form.start_year_2026_or_later? ? 1 : 0
    @max = 80
    @step = 1
    @width = 5
    @ownershipsch = ownershipsch
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR_AND_SECTION, value_key: form.start_year_2026_or_later? ? subsection.id : ownershipsch)
  end

  def suffix_label(log)
    " #{'year'.pluralize(log[id])}"
  end

  QUESTION_NUMBER_FROM_YEAR_AND_SECTION = {
    2023 => { 1 => 75, 2 => 99 },
    2024 => { 1 => 77, 2 => 100 },
    2025 => { 1 => 75, 2 => 102 },
    2026 => { "shared_ownership_initial_purchase" => 83, "discounted_ownership_scheme" => 112 },
  }.freeze
end
