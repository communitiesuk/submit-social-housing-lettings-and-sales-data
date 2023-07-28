class Form::Sales::Pages::Organisation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "organisation"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::OwningOrganisationId.new(nil, nil, self),
    ]
  end

  def routed_to?(_log, current_user)
    !!current_user&.support? || current_user&.organisation&.absorbed_organisations.present?
  end
end
