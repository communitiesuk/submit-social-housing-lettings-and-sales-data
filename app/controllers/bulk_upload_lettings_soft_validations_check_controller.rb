class BulkUploadLettingsSoftValidationsCheckController < ApplicationController
  include ActionView::Helpers::TextHelper

  before_action :authenticate_user!
  before_action :set_no_cache_headers

  def set_no_cache_headers
    response.set_header("Cache-Control", "no-store")
  end

  def show
    @bulk_upload = current_user.bulk_uploads.find(params[:id])

    return redirect_to form.preflight_redirect unless form.preflight_valid?

    render form.view_path
  end

  def update
    @bulk_upload = current_user.bulk_uploads.find(params[:id])

    if form.valid? && form.save!
      if params[:page] == "confirm"
        n_logs = pluralize(@bulk_upload.logs.count, "log")
        flash[:notice] = "You’ve successfully uploaded #{n_logs}"
      end

      redirect_to form.next_path
    else
      render form.view_path
    end
  end

private

  def form
    @form ||= case params[:page]
              when "confirm-soft-errors"
                Forms::BulkUploadSoftValidationsCheck::ConfirmSoftErrors.new(form_params.merge(bulk_upload: @bulk_upload, log_type: "lettings"))
              when "chosen"
                Forms::BulkUploadSoftValidationsCheck::Chosen.new(form_params.merge(bulk_upload: @bulk_upload, log_type: "lettings"))
              when "confirm"
                Forms::BulkUploadSoftValidationsCheck::Confirm.new(form_params.merge(bulk_upload: @bulk_upload, log_type: "lettings"))
              else
                raise "invalid form"
              end
  end

  def form_params
    params.fetch(:form, {}).permit(:confirm_soft_errors)
  end
end
