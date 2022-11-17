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
    return true unless current_user.organisation.holds_own_stock?

    return true if current_user.organisation.housing_providers.count.positive?

    log.update!(owning_organisation: current_user.organisation)

    false
  end
end
