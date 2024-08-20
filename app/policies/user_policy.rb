class UserPolicy
  attr_reader :current_user, :user

  def initialize(current_user, user)
    @current_user = current_user
    @user = user
  end

  def edit_password?
    @current_user == @user
  end

  %w[
    edit_roles?
    edit_dpo?
    edit_key_contact?
  ].each do |method_name|
    define_method method_name do
      return true if @current_user.support?

      @current_user.data_coordinator? && @user.active?
    end
  end

  %w[
    edit_emails?
    edit_telephone_numbers?
    edit_names?
  ].each do |method_name|
    define_method method_name do
      return true if @current_user.support?

      (@current_user == @user || @current_user.data_coordinator?) && @user.active?
    end
  end

  def delete_confirmation?
    delete?
  end

  def delete?
    return false unless current_user.support?
    return false unless user.status == :deactivated

    !has_any_logs_in_editable_collection_period && !has_signed_data_protection_agreement?
  end

  %w[
    edit_organisation?
    log_reassignment?
    update_log_reassignment?
    organisation_change_confirmation?
    confirm_organisation_change?
  ].each do |method_name|
    define_method method_name do
      @current_user.support?
    end
  end

private

  def has_any_logs_in_editable_collection_period
    editable_from_date = FormHandler.instance.earliest_open_for_editing_collection_start_date

    LettingsLog.where(assigned_to_id: user.id).after_date(editable_from_date).or(LettingsLog.where(startdate: nil, assigned_to_id: user.id)).any?
  end

  def has_signed_data_protection_agreement?
    return false unless user.is_dpo? && user.organisation.data_protection_confirmed?

    user.organisation.data_protection_confirmation.data_protection_officer == user
  end
end
