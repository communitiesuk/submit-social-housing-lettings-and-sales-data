class Form::Lettings::Pages::TenantCode < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "tenant_code"
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::TenantCode.new(nil, nil, self),
    ]
  end
end
