class UserPolicy
  attr_reader :current_user, :user

  def initialize(current_user, user)
    @current_user = current_user
    @user = user
  end

  def edit_password?
    @current_user == @user
  end

  def edit_roles?
    (@current_user.data_coordinator? || @current_user.support?) && @user.active?
  end

  %w[
    edit_roles?
    edit_dpo?
    edit_key_contact?
  ].each do |method_name|
    define_method method_name do
      (@current_user.data_coordinator? || @current_user.support?) && @user.active?
    end
  end

  %w[
    edit_emails?
    edit_telephone_numbers?
    edit_names?
  ].each do |method_name|
    define_method method_name do
      (@current_user == @user || @current_user.data_coordinator? || @current_user.support?) && @user.active?
    end
  end
end
