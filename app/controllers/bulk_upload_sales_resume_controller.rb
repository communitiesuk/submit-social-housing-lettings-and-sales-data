class BulkUploadSalesResumeController < ApplicationController
  before_action :authenticate_user!
  before_action :set_no_cache_headers

  def set_no_cache_headers
    response.set_header("Cache-Control", "no-store")
  end

  def start
    @bulk_upload = current_user.bulk_uploads.find(params[:id])

    redirect_to page_bulk_upload_sales_resume_path(@bulk_upload, page: "fix-choice")
  end

  def show
    @bulk_upload = current_user.bulk_uploads.find(params[:id])
    @soft_errors_only = params[:soft_errors_only] == "true"

    return redirect_to form.preflight_redirect unless form.preflight_valid?

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

  def deletion_report
    @bulk_upload = BulkUpload.sales.find(params[:id])

    authorize @bulk_upload
  end

private

  def form
    @form ||= case params[:page]
              when "fix-choice"
                Forms::BulkUploadResume::FixChoice.new(form_params.merge(bulk_upload: @bulk_upload, log_type: "sales"))
              when "chosen"
                Forms::BulkUploadResume::Chosen.new(form_params.merge(bulk_upload: @bulk_upload, log_type: "sales"))
              when "confirm"
                Forms::BulkUploadResume::Confirm.new(form_params.merge(bulk_upload: @bulk_upload, log_type: "sales"))
              when "deletion-report"
                Forms::BulkUploadResume::DeletionReport.new(form_params.merge(bulk_upload: @bulk_upload, log_type: "sales"))
              else
                raise "invalid form"
              end
  end

  def form_params
    params.fetch(:form, {}).permit(:choice)
  end
end
