class Form::Lettings::Pages::TenancyType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "tenancy_type"
    @depends_on = [{ "starter_tenancy?" => false }]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::TenancyType.new(nil, nil, self),
      Form::Lettings::Questions::TenancyOther.new(nil, nil, self),
    ]
  end
end
