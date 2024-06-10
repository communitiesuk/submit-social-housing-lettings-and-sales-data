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

  def delete_confirmation?
    delete?
  end

  def delete?
    user.support? && (organisation.status == :deactivated || organisation.status == :merged)
  end
end
