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
      scheme_owned_by_user_org_or_stock_owner
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

    user.data_coordinator? && scheme_owned_by_user_org_or_stock_owner
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

      scheme_owned_by_user_org_or_stock_owner
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

      user.data_coordinator? && scheme_owned_by_user_org_or_stock_owner
    end
  end

private

  def scheme_owned_by_user_org_or_stock_owner
    scheme&.owning_organisation == user.organisation || user.organisation.stock_owners.exists?(scheme&.owning_organisation_id)
  end
end
