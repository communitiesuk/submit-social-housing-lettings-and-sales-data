class OrganisationPolicy
  attr_reader :user, :organisation

  def initialize(user, organisation)
    @user = user
    @organisation = organisation
  end

  %w[
    deactivate?
    reactivate?
  ].each do |method_name|
    define_method method_name do
      user.support?
    end
  end
end
