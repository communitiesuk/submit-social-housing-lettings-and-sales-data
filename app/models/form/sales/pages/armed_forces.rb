class Form::Sales::Pages::ArmedForces < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "armed_forces"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::ArmedForces.new(nil, nil, self),
    ]
  end
end
