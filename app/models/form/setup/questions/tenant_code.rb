class Form::Setup::Questions::TenantCode < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "tenant_code"
    @check_answer_label = "Tenant code"
    @header = "What is the tenant code?"
    @hint_text = "This is how you usually refer to this tenancy on your own systems."
    @type = "text"
    @width = 10
    @page = page
  end
end
