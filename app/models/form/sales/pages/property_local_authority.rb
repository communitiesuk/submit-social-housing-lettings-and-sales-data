class Form::Sales::Pages::PropertyLocalAuthority < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_local_authority"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PropertyLocalAuthorityKnown.new(nil, nil, self),
      Form::Sales::Questions::PropertyLocalAuthority.new(nil, nil, self),
    ]
  end
end
