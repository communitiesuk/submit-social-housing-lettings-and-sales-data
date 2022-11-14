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

  # For an organisation owns and manages ONLY their own housing stock AND NOT uses agents to manage the properties AND NOT manages housing stock of other organisations?
  # In "set up this lettings log" no extra question should be shown
  def routed_to?(log, current_user)
    return false unless current_user
    return true if current_user.support?
    return true unless current_user.organisation.holds_own_stock?

    managing_agents = current_user.organisation.managing_agents

    return false if managing_agents.count.zero?
    return true if managing_agents.count > 1

    log.update!(managing_organisation: managing_agents.first)

    false
  end
end
