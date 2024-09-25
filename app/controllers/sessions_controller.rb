class SessionsController < ApplicationController
  def clear_filters
    session[session_name_for(params[:filter_type])] = "{}"
    path_params = params[:path_params].presence || {}

    if path_params[:organisation_id].present?
      redirect_to send("#{params[:filter_type]}_organisation_path", id: path_params[:organisation_id], scheme_id: path_params[:scheme_id], search: path_params[:search])
    elsif params[:filter_type].include?("bulk_uploads")
      bulk_upload_type = params[:filter_type].split("_").first
      uploading_organisation = params[:organisation_id].presence
      if uploading_organisation.present?
        redirect_to send("bulk_uploads_#{bulk_upload_type}_logs_path", search: path_params[:search], uploading_organisation:)
      else
        redirect_to send("bulk_uploads_#{bulk_upload_type}_logs_path", search: path_params[:search])
      end
    else
      redirect_to send("#{params[:filter_type]}_path", scheme_id: path_params[:scheme_id], search: path_params[:search])
    end
  end

private

  def session_name_for(filter_type)
    "#{filter_type}_filters"
  end
end
