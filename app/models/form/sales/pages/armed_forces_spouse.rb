class Form::Sales::Pages::ArmedForcesSpouse < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "armed_forces_spouse"
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::ArmedForcesSpouse.new(nil, nil, self),
    ]
  end
end
