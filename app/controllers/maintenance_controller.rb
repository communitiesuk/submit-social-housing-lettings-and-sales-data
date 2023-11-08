class MaintenanceController < ApplicationController
  def service_unavailable
    if current_user
      sign_out
    end
  end
end
