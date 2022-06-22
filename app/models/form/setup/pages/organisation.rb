class Form::Setup::Pages::Organisation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "organisation"
    @header = ""
    @description = ""
    @questions = questions
    @subsection = subsection
  end

  def questions
    [
      Form::Setup::Questions::OwningOrganisationId.new(nil, nil, self),
    ]
  end

  def routed_to?(_case_log, current_user)
    !!current_user&.support?
  end
end
