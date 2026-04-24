class Form::Sales::Questions::PrivacyNotice < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "privacynotice"
    @copy_key = "sales.#{subsection.copy_key}.privacynotice.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}"
    @type = "checkbox"
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
    @joint_purchase = joint_purchase
    @top_guidance_partial = guidance
  end

  def answer_options
    { "privacynotice" => { "value" => "The #{@joint_purchase ? 'buyers have' : 'buyer has'} seen or been given access to the MHCLG privacy notice" } }.freeze
  end

  def unanswered_error_message
    buyer_or_buyers = @joint_purchase ? "buyers" : "buyer"
    I18n.t("validations.privacynotice.missing", buyer_or_buyers:)
  end

  def guidance
    @joint_purchase ? "privacy_notice_buyer_joint_purchase" : "privacy_notice_buyer"
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 19, 2024 => 14, 2025 => 12, 2026 => 12 }.freeze
end
