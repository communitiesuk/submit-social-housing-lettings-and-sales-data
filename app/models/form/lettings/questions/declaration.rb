class Form::Lettings::Questions::Declaration < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "declaration"
    @type = "checkbox"
    @top_guidance_partial = "privacy_notice_tenant"
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  def answer_options
    { "declaration" => { "value" => "The tenant has seen or been given access to the MHCLG privacy notice" } }.freeze
  end

  def unanswered_error_message
    I18n.t("validations.declaration.missing")
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 30, 2024 => 11, 2025 => 11, 2026 => 11 }.freeze
end
