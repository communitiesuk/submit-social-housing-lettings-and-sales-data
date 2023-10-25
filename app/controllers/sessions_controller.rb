class SessionsController < ApplicationController
  def clear_filters
    session[session_name_for(params[:filter_type])] = "{}"
    path_params = params[:path_params].presence || {}

    redirect_to send("#{params[:filter_type]}_path", scheme_id: path_params[:scheme_id], search: path_params[:search])
  end

private

  def session_name_for(filter_type)
    "#{filter_type}_filters"
  end
end
