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

    if location == Location
      user.data_coordinator?
    else
      user.data_coordinator? && scheme_owned_by_user_org_or_stock_owner
    end
  end

  def update?
    return true if user.support?

    user.data_coordinator? && scheme_owned_by_user_org_or_stock_owner
  end

  def delete_confirmation?
    delete?
  end

  def delete?
    return false unless user.support?
    return false unless location.status == :incomplete || location.status == :deactivated

    !has_any_logs_in_editable_collection_period
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

      user.data_coordinator? && scheme_owned_by_user_org_or_stock_owner
    end
  end

  %w[
    show?
    check_answers?
  ].each do |method_name|
    define_method method_name do
      return true if user.support?

      scheme_owned_by_user_org_or_stock_owner
    end
  end

private

  def scheme
    location.scheme
  end

  def scheme_owned_by_user_org_or_stock_owner
    scheme&.owning_organisation == user.organisation || user.organisation.stock_owners.exists?(scheme&.owning_organisation_id)
  end

  def has_any_logs_in_editable_collection_period
    editable_from_date = FormHandler.instance.earliest_open_for_editing_collection_start_date
    editable_logs = LettingsLog.where(location_id: location.id).after_date(editable_from_date)

    LettingsLog.where(location_id: location.id, startdate: nil).any? || editable_logs.any?
  end
end
