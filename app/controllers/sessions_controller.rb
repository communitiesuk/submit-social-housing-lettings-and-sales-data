class SessionsController < ApplicationController
  def clear_filters
    session[session_name_for(params[:filter_type])] = "{}"

    redirect_to send("#{params[:filter_type]}_path", scheme_id: params[:path_params][:scheme_id])
  end

private

  def session_name_for(filter_type)
    "#{filter_type}_filters"
  end
end
