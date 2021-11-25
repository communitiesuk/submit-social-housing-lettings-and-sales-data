class Users::AccountController < ApplicationController
    def check_logged_in
        if current_user.nil?
            redirect_to(new_user_session_path())
        end
    end

    def index
        check_logged_in
    end
    
    def personal_details
        check_logged_in
    end

    def update
        if current_user.update('name': params[:user][:name], 'email': params[:user][:email],)
            redirect_to(users_account_path())
        end
    end
end