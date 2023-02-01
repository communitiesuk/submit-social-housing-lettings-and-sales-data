class Form::Lettings::Pages::ArmedForces < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "armed_forces"
    @header = ""
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Armedforces.new(nil, nil, self)]
  end
end
