class Form::Sales::Pages::Mortgageused < ::Form::Page
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @ownershipsch = ownershipsch
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Mortgageused.new(nil, nil, self, ownershipsch: @ownershipsch),
    ]
  end
end
