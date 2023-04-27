class BulkUploadLettingsResumeController < ApplicationController
  before_action :authenticate_user!

  def start
    @bulk_upload = current_user.bulk_uploads.find(params[:id])

    redirect_to page_bulk_upload_lettings_resume_path(@bulk_upload, page: "fix-choice")
  end

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
              when "fix-choice"
                Forms::BulkUploadLettingsResume::FixChoice.new(form_params.merge(bulk_upload: @bulk_upload))
              when "confirm"
                Forms::BulkUploadLettingsResume::Confirm.new(form_params.merge(bulk_upload: @bulk_upload))
              else
                raise "invalid form"
              end
  end

  def form_params
    params.fetch(:form, {}).permit(:choice)
  end
end
