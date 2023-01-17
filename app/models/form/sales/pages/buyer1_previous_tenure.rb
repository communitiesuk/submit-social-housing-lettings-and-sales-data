class Form::Sales::Pages::Buyer1PreviousTenure < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer1_previous_tenure"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer1PreviousTenure.new(nil, nil, self),
    ]
  end
end
