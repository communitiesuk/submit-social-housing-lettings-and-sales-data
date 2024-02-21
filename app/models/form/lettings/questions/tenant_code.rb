class Form::Lettings::Questions::TenantCode < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "tenancycode"
    @check_answer_label = "Tenant code"
    @header = "What is the tenant code?"
    @hint_text = "This is how you usually refer to this tenancy on your own systems."
    @type = "text"
    @width = 10
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last) if form.start_date.present?
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 7, 2024 => 9 }.freeze
end
