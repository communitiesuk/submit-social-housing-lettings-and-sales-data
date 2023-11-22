class Form::Sales::Pages::ManagingOrganisation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "managing_organisation"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::ManagingOrganisation.new(nil, nil, self),
    ]
  end

  def routed_to?(log, current_user)
    return false unless current_user
    return false unless current_user.support?
    return false unless FeatureToggle.sales_managing_organisation_enabled?
    return false unless log.owning_organisation

    log.owning_organisation.managing_agents.count >= 1
  end
end
