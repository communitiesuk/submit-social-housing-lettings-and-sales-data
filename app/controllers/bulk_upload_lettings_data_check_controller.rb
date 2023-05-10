class BulkUploadLettingsDataCheckController < ApplicationController
  before_action :authenticate_user!

  def show
    @bulk_upload = current_user.bulk_uploads.find(params[:id])

    render form.view_path
  end

  def update
    @bulk_upload = current_user.bulk_uploads.find(params[:id])

    if form.valid? && form.save!
      redirect_to form.next_path
    else
      render form.view_path
    end
  end

private

  def form
    @form ||= case params[:page]
              when "soft-errors-valid"
                Forms::BulkUploadLettingsDataCheck::SoftErrorsValid.new(form_params.merge(bulk_upload: @bulk_upload))
              when "confirm"
                Forms::BulkUploadLettingsDataCheck::Confirm.new(form_params.merge(bulk_upload: @bulk_upload))
              else
                raise "invalid form"
              end
  end

  def form_params
    params.fetch(:form, {}).permit(:soft_errors_valid)
  end
end
