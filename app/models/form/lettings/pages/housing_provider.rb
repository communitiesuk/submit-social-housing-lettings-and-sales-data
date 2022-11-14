class Form::Lettings::Pages::HousingProvider < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "housing_provider"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::HousingProvider.new(nil, nil, self),
    ]
  end

  # For an organisation owns and manages ONLY their own housing stock AND NOT uses agents to manage the properties AND NOT manages housing stock of other organisations?
  # In "set up this lettings log" no extra question should be shown
  def routed_to?(log, current_user)
    return false unless current_user
    return true if current_user.support?
    return true unless current_user.organisation.holds_own_stock?

    housing_providers = current_user.organisation.housing_providers

    return false if housing_providers.count.zero?
    return true if housing_providers.count > 1

    log.update!(owning_organisation: housing_providers.first)

    false
  end
end
