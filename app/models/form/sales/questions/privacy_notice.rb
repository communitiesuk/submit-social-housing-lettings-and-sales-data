class Form::Sales::Questions::PrivacyNotice < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "privacynotice"
    @check_answer_label = "#{joint_purchase ? 'Buyers have' : 'Buyer has'} seen the privacy notice?"
    @header = "Declaration"
    @type = "checkbox"
    @top_guidance_partial = form.start_year_after_2024? ? "privacy_notice_buyer_2024" : "privacy_notice_buyer"
    @question_number = 19
    @joint_purchase = joint_purchase
  end

  def answer_options
    declaration_text = if form.start_year_after_2024?
                         "The #{@joint_purchase ? 'buyers have' : 'buyer has'} seen or been given access to the DLUHC privacy notice"
                       else
                         "The #{@joint_purchase ? 'buyers have' : 'buyer has'} seen the DLUHC privacy notice"
                       end

    { "privacynotice" => { "value" => declaration_text } }.freeze
  end
end
