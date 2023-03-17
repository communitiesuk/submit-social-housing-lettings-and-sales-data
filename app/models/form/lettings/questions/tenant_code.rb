class Form::Lettings::Questions::TenantCode < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "tenancycode"
    @check_answer_label = "Tenant code"
    @header = "What is the tenant code?"
    @hint_text = "This is how you usually refer to this tenancy on your own systems."
    @type = "text"
    @width = 10
    @question_number = 7
  end
end
