class LocationPolicy
  attr_reader :user, :location

  def initialize(user, location)
    @user = user
    @location = location
  end

  def index?
    true
  end

  def create?
    return true if user.support?

    user.data_coordinator? && user.organisation == scheme&.owning_organisation
  end

  def update?
    return true if user.support?

    user.data_coordinator? && scheme&.owning_organisation == user.organisation
  end

  %w[
    update_postcode?
    update_local_authority?
    update_name?
    update_units?
    update_type_of_unit?
    update_mobility_standards?
    update_availability?
    new_deactivation?
    deactivate_confirm?
    deactivate?
    new_reactivation?
    reactivate?
    postcode?
    local_authority?
    name?
    units?
    type_of_unit?
    mobility_standards?
    availability?
    confirm?
  ].each do |method_name|
    define_method method_name do
      return true if user.support?

      user.data_coordinator? && scheme&.owning_organisation == user.organisation
    end
  end

  %w[
    show?
    check_answers?
  ].each do |method_name|
    define_method method_name do
      return true if user.support?

      scheme&.owning_organisation == user.organisation
    end
  end

private

  def scheme
    location.scheme
  end
end
