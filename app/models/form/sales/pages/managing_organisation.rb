class Form::Sales::Pages::ManagingOrganisation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "managing_organisation"
    @copy_key = "sales.setup.managing_organisation_id"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::ManagingOrganisation.new(nil, nil, self),
    ]
  end

  def routed_to?(log, current_user)
    return false unless current_user

    if form.start_year_after_2024?
      organisation = current_user.support? ? log.owning_organisation : current_user.organisation

      return false unless organisation
      return false if log.owning_organisation != organisation && !organisation.holds_own_stock?
      return true unless organisation.holds_own_stock?

      organisation.managing_agents.count >= 1
    else
      return false unless current_user.support?
      return false unless log.owning_organisation

      log.owning_organisation.managing_agents.count >= 1
    end
  end
end
