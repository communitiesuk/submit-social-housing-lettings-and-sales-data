class OrganisationRelationshipPolicy
  attr_reader :user, :organisation_relationship

  def initialize(user, organisation_relationship)
    @user = user
    @organisation_relationship = organisation_relationship
  end

  def create_stock_owner?
    return true unless user.data_provider?
  end

  def remove_stock_owner?
    return true unless user.data_provider?
  end
end
