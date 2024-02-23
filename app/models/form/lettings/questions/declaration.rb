class Form::Lettings::Questions::Declaration < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "declaration"
    @check_answer_label = "Tenant has seen the privacy notice"
    @header = "Declaration"
    @type = "checkbox"
    @check_answers_card_number = 0 unless form.start_year_after_2024?
    @top_guidance_partial = form.start_year_after_2024? ? "privacy_notice_tenant_2024" : "privacy_notice_tenant"
    @question_number = QUESTION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  def answer_options
    declaration_text = if form.start_year_after_2024?
                         "The tenant has seen or been given access to the DLUHC privacy notice"
                       else
                         "The tenant has seen the DLUHC privacy notice"
                       end

    { "declaration" => { "value" => declaration_text } }.freeze
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 30, 2024 => 11 }.freeze
end
