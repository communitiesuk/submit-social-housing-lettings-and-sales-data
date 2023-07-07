class OrganisationRelationshipPolicy
  attr_reader :user, :organisation_relationship

  def initialize(user, organisation_relationship)
    @user = user
    @organisation_relationship = organisation_relationship
  end

  %w[
    add_stock_owner?
    create_stock_owner?
    remove_stock_owner?
    add_managing_agent?
    create_managing_agent?
    remove_managing_agent?
  ].each do |method_name|
    define_method method_name do
      !user.data_provider?
    end
  end
end
