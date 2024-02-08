class Form::Sales::Questions::PrivacyNotice < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "privacynotice"
    @check_answer_label = "Buyer has seen the privacy notice?"
    @header = "Declaration"
    @type = "checkbox"
    @top_guidance_partial = form.start_year_after_2024? ? "privacy_notice_buyer_2024" : "privacy_notice_buyer"
    @question_number = 19
  end

  def answer_options
    declaration_text = if form.start_year_after_2024?
                         "The buyer has seen or been given access to the DLUHC privacy notice"
                       else
                         "The buyer has seen the DLUHC privacy notice"
                       end

    { "privacynotice" => { "value" => declaration_text } }.freeze
  end
end
