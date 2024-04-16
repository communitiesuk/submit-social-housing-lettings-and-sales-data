class OrganisationPolicy
  attr_reader :user, :organisation

  def initialize(user, organisation)
    @user = user
    @organisation = organisation
  end

  def deactivate?
    user.support? && organisation.status == :active
  end

  def reactivate?
    user.support? && organisation.status == :deactivated
  end
end
