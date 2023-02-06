class Form::Lettings::Pages::PropertyLocalAuthority < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_local_authority"
    @depends_on = [{ "is_la_inferred" => false, "needstype" => 1 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::La.new(nil, nil, self)]
  end
end
