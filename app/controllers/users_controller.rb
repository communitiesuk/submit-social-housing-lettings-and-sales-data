class UsersController < ApplicationController
  include Devise::Controllers::SignInOut
  before_action :authenticate_user!

  def update
    if current_user.update(user_params)
      bypass_sign_in current_user
      redirect_to user_path(current_user)
    end
  end

  def new
    @resource = User.new
  end

  def create
    @user = User.create!(user_params.merge(org_params))
    redirect_to @user
  end

  def edit_password
    render :edit_password
  end

private

  def org_params
    { organisation: current_user.organisation }
  end

  def user_params
    params.require(:user).permit(:email, :name, :password)
  end
end
