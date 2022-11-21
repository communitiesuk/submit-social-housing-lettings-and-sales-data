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

  def routed_to?(log, current_user)
    return false unless current_user
    return true if current_user.support?

    housing_providers = current_user.organisation.housing_providers

    if current_user.organisation.holds_own_stock?
      return true if housing_providers.count >= 1

      log.update!(owning_organisation: current_user.organisation)
    else
      return false if housing_providers.count.zero?
      return true if housing_providers.count > 1

      log.update!(owning_organisation: housing_providers.first)
    end

    false
  end
end
