class Form::Setup::Pages::Organisation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "organisation"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Setup::Questions::OwningOrganisationId.new(nil, nil, self),
    ]
  end

  def routed_to?(_log, current_user)
    !!current_user&.support?
  end
end
