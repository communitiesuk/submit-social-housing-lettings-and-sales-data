class Form::Lettings::Questions::Declaration < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "declaration"
    @type = "checkbox"
    @check_answers_card_number = 0 unless form.start_year_2024_or_later?
    @top_guidance_partial = "privacy_notice_tenant"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  def answer_options
    declaration_text = if form.start_year_2024_or_later?
                         "The tenant has seen or been given access to the MHCLG privacy notice"
                       else
                         "The tenant has seen the MHCLG privacy notice"
                       end

    { "declaration" => { "value" => declaration_text } }.freeze
  end

  def unanswered_error_message
    if form.start_year_2024_or_later?
      I18n.t("validations.declaration.missing.post_2024")
    else
      I18n.t("validations.declaration.missing.pre_2024")
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 30, 2024 => 11, 2025 => 11, 2026 => 11 }.freeze
end
