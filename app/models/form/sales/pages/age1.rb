class Form::Sales::Pages::Age1 < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_age"
    @header = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer1AgeKnown.new(nil, nil, self),
      Form::Sales::Questions::Age1.new(nil, nil, self),
    ]
  end
end
