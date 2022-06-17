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

  def routed_to?(_case_log)
    !!form.current_user&.support?
  end

  def invalidated?(case_log)
    false
  end
end
