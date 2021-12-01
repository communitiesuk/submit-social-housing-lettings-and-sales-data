class Users::AccountController < ApplicationController
  def index
    check_logged_in
  end

  def edit
    check_logged_in
  end

  def update
    if current_user.update(user_params)
      redirect_to(users_account_path)
    end
  end

private

  def check_logged_in
    if current_user.nil?
      redirect_to(new_user_session_path)
    end
  end

  def user_params
    params.require(:user).permit(:email, :name, :password)
  end
end
