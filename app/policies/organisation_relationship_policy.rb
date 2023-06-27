class OrganisationRelationshipPolicy
  attr_reader :user, :organisation_relationship

  def initialize(user, organisation_relationship)
    @user = user
    @organisation_relationship = organisation_relationship
  end

  def add_stock_owner?
    return true unless user.data_provider?
  end

  def create_stock_owner?
    return true unless user.data_provider?
  end

  def remove_stock_owner?
    return true unless user.data_provider?
  end

  def add_managing_agent?
    return true unless user.data_provider?
  end

  def create_managing_agent?
    return true unless user.data_provider?
  end

  def remove_managing_agent?
    return true unless user.data_provider?
  end
end
