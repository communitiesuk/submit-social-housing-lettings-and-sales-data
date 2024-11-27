class SchemePolicy
  attr_reader :user, :scheme

  def initialize(user, scheme)
    @user = user
    @scheme = scheme
  end

  def index?
    return true if user.support?

    if scheme == Scheme
      true
    else
      scheme_owned_by_user_org_or_stock_owner_or_recently_absorbed_org
    end
  end

  def new?
    user.data_coordinator? || user.support?
  end

  def create?
    user.data_coordinator? || user.support?
  end

  def update?
    return true if user.support?

    user.data_coordinator? && scheme_owned_by_user_org_or_stock_owner_or_recently_absorbed_org
  end

  def changes?
    true
  end

  %w[
    show?
    check_answers?
  ].each do |method_name|
    define_method method_name do
      return true if user.support?

      scheme_owned_by_user_org_or_stock_owner_or_recently_absorbed_org
    end
  end

  %w[
    edit_name?
    primary_client_group?
    confirm_secondary_client_group?
    secondary_client_group?
    new_deactivation?
    new_reactivation?
    deactivate?
    reactivate?
    details?
    support?
    deactivate_confirm?
  ].each do |method_name|
    define_method method_name do
      return true if user.support?

      user.data_coordinator? && scheme_owned_by_user_org_or_stock_owner_or_recently_absorbed_org
    end
  end

  def delete_confirmation?
    delete?
  end

  def delete?
    return false unless user.support?
    return false unless scheme.status == :incomplete || scheme.status == :deactivated

    !has_any_logs_in_editable_collection_period
  end

private

  def scheme_owned_by_user_org_or_stock_owner_or_recently_absorbed_org
    scheme_owned_by_user_org = scheme&.owning_organisation == user.organisation
    scheme_owned_by_stock_owner = user.organisation.stock_owners.exists?(scheme&.owning_organisation_id)
    scheme_owned_by_recently_absorbed_org = user.organisation.absorbed_organisations.visible.merged_during_open_collection_period.exists?(scheme&.owning_organisation_id)
    scheme_owned_by_user_org || scheme_owned_by_stock_owner || scheme_owned_by_recently_absorbed_org
  end

  def has_any_logs_in_editable_collection_period
    editable_from_date = FormHandler.instance.earliest_open_for_editing_collection_start_date

    LettingsLog.where(scheme_id: scheme.id).after_date(editable_from_date).or(LettingsLog.where(startdate: nil, scheme_id: scheme.id)).any?
  end
end
