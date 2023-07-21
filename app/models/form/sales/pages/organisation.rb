class Form::Sales::Pages::Organisation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "organisation"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::OwningOrganisationId.new(nil, nil, self),
    ]
  end
end
