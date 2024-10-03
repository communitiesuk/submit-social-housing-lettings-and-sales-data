class Form::Sales::Pages::OwnershipScheme < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "ownership_scheme"
    @copy_key = "sales.setup.ownershipsch"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::OwnershipScheme.new(nil, nil, self),
    ]
  end
end
