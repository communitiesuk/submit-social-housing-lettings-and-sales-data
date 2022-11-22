class Form::Lettings::Pages::ManagingOrganisation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "managing_organisation"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::ManagingOrganisation.new(nil, nil, self),
    ]
  end

  def routed_to?(log, current_user)
    return false unless current_user

    organisation = if current_user.support?
                     log.owning_organisation
                   else
                     current_user.organisation
                   end

    return false unless organisation
    return true unless organisation.holds_own_stock?

    organisation.managing_agents.count > 1
  end
end
