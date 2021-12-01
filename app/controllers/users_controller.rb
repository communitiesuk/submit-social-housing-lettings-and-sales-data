class UsersController < ApplicationController
  before_action :authenticate_user!

  def update
    if current_user.update(user_params)
      redirect_to(user_path)
    end
  end

  def new
    @resource = User.new
  end

  def create
    User.create!(user_params)
  end

  def edit_password
    render :edit_password
  end

private

  def user_params
    params.require(:user).permit(:email, :name, :password)
  end
end
