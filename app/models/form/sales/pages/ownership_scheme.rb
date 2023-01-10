class Form::Sales::Pages::OwnershipScheme < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "ownership_scheme"
    @header = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::OwnershipScheme.new(nil, nil, self),
    ]
  end
end
