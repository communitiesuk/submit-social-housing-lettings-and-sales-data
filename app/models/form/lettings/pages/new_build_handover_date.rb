class Form::Lettings::Pages::NewBuildHandoverDate < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "new_build_handover_date"
    @depends_on = [{ "is_renewal?" => false, "has_first_let_vacancy_reason?" => true }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::VoiddateNewBuild.new(nil, nil, self)]
  end
end
