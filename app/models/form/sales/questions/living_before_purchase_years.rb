class Form::Sales::Questions::LivingBeforePurchaseYears < ::Form::Question
  def initialize(id, hsh, page, ownershipsch:, joint_purchase:)
    super(id, hsh, page)
    @id = "proplen"
    @copy_key = "sales.sale_information.living_before_purchase.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}.proplen"
    @type = "numeric"
    @min = 0
    @max = 80
    @step = 1
    @width = 5
    @ownershipsch = ownershipsch
    @question_number = question_number
  end

  def suffix_label(log)
    " #{'year'.pluralize(log[id])}"
  end

  QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP = {
    2023 => { 1 => 75, 2 => 99 },
    2024 => { 1 => 77, 2 => 101 },
  }.freeze
end
