class Form::Lettings::Pages::NewBuildHandoverDate < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "new_build_handover_date"
    @depends_on = [
      { "renewal" => 0, "rsnvac" => 15 },
      { "renewal" => 0, "rsnvac" => 16 },
      { "renewal" => 0, "rsnvac" => 17 },
    ]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::VoiddateNewBuild.new(nil, nil, self)]
  end
end
