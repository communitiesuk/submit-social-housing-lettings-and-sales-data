class Users::AccountController < ApplicationController
    def index; end
    def personal_details; end

    def update
        if current_user.update('name': params[:user][:name], 'email': params[:user][:email],)
            redirect_to(users_account_path())
        end
    end
end