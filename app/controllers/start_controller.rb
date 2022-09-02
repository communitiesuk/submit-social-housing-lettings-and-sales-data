class StartController < ApplicationController
  def index
    if current_user
      redirect_to(lettings_logs_path)
    end
  end
end
