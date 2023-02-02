class Form::Lettings::Pages::ArmedForcesServing < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "armed_forces_serving"
    @depends_on = [{ "armedforces" => 1 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Leftreg.new(nil, nil, self)]
  end
end
