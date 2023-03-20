class Form::Sales::Pages::UprnKnown < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "uprn_known"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::UprnKnown.new(nil, nil, self),
    ]
  end
end
