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
      scheme&.owning_organisation == user.organisation
    end
  end

  def new?
    user.data_coordinator? || user.support?
  end

  def create?
    user.data_coordinator? || user.support?
  end

  def update?
    user.data_coordinator? || user.support?
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

  %w[
    edit_name?
    primary_client_group?
    confirm_secondary_client_group?
    secondary_client_group?
    new_deactivation?
    deactivate?
    details?
    support?
    deactivate_confirm?
  ].each do |method_name|
    define_method method_name do
      return true if user.support?

      user.data_coordinator? && scheme&.owning_organisation == user.organisation
    end
  end
end
