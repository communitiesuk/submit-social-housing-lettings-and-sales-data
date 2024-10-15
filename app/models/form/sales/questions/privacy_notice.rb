class Form::Sales::Questions::PrivacyNotice < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "privacynotice"
    @copy_key = "sales.setup.privacynotice.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}"
    @type = "checkbox"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @joint_purchase = joint_purchase
    @top_guidance_partial = guidance
  end

  def answer_options
    declaration_text = if form.start_year_after_2024?
                         "The #{@joint_purchase ? 'buyers have' : 'buyer has'} seen or been given access to the MHCLG privacy notice"
                       else
                         "The #{@joint_purchase ? 'buyers have' : 'buyer has'} seen the MHCLG privacy notice"
                       end

    { "privacynotice" => { "value" => declaration_text } }.freeze
  end

  def unanswered_error_message
    buyer_or_buyers = @joint_purchase ? "buyers" : "buyer"
    if form.start_year_after_2024?
      I18n.t("validations.privacynotice.missing.post_2024", buyer_or_buyers:)
    else
      I18n.t("validations.privacynotice.missing.pre_2024", buyer_or_buyers:)
    end
  end

  def guidance
    if form.start_year_after_2024?
      @joint_purchase ? "privacy_notice_buyer_2024_joint_purchase" : "privacy_notice_buyer_2024"
    else
      @joint_purchase ? "privacy_notice_buyer_joint_purchase" : "privacy_notice_buyer"
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 19, 2024 => 14 }.freeze
end
