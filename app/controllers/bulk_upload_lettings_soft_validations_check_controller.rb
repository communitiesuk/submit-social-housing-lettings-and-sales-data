class BulkUploadLettingsSoftValidationsCheckController < ApplicationController
  include ActionView::Helpers::TextHelper

  before_action :authenticate_user!

  def show
    @bulk_upload = current_user.bulk_uploads.find(params[:id])

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
                Forms::BulkUploadLettingsSoftValidationsCheck::ConfirmSoftErrors.new(form_params.merge(bulk_upload: @bulk_upload))
              when "confirm"
                Forms::BulkUploadLettingsSoftValidationsCheck::Confirm.new(form_params.merge(bulk_upload: @bulk_upload))
              else
                raise "invalid form"
              end
  end

  def form_params
    params.fetch(:form, {}).permit(:confirm_soft_errors)
  end
end
