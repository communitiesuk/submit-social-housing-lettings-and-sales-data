class Form::Lettings::Questions::Declaration < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "declaration"
    @check_answer_label = "Tenant has seen the privacy notice"
    @header = "Declaration"
    @type = "checkbox"
    @check_answers_card_number = 0 unless form.start_year_after_2024?
    @top_guidance_partial = form.start_year_after_2024? ? "privacy_notice_tenant_2024" : "privacy_notice_tenant"
    @question_number = 30
  end

  def answer_options
    declaration_text = if form.start_year_after_2024?
                         "The tenant has seen or been given access to the DLUHC privacy notice"
                       else
                         "The tenant has seen the DLUHC privacy notice"
                       end

    { "declaration" => { "value" => declaration_text } }.freeze
  end
end
