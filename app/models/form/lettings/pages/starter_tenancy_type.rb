class Form::Lettings::Pages::StarterTenancyType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "starter_tenancy_type"
    @depends_on = [{ "starter_tenancy?" => true }]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::StarterTenancyType.new(nil, nil, self),
      Form::Lettings::Questions::TenancyOther.new(nil, nil, self),
    ]
  end
end
