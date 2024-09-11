class BulkUploadSalesLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_data_protection_agrement_signed!

  def start
    if current_user.support? && params[:organisation_id].present?
      redirect_to bulk_upload_sales_log_path(id: "upload-your-file", form: { year: current_year }, organisation_id: params[:organisation_id])
    elsif have_choice_of_year?
      redirect_to bulk_upload_sales_log_path(id: "year")
    else
      redirect_to bulk_upload_sales_log_path(id: "prepare-your-file", form: { year: current_year })
    end
  end

  def show
    render form.view_path
  end

  def update
    if form.valid? && form.save!
      redirect_to form.next_path
    else
      render form.view_path
    end
  end

private

  def validate_data_protection_agrement_signed!
    return if @current_user.organisation.data_protection_confirmed?

    redirect_to sales_logs_path
  end

  def current_year
    FormHandler.instance.current_collection_start_year
  end

  def have_choice_of_year?
    return true if FeatureToggle.allow_future_form_use?

    FormHandler.instance.sales_in_crossover_period?
  end

  def form
    @form ||= case params[:id]
              when "year"
                Forms::BulkUploadSales::Year.new(form_params)
              when "prepare-your-file"
                Forms::BulkUploadSales::PrepareYourFile.new(form_params)
              when "guidance"
                Forms::BulkUploadSales::Guidance.new(form_params.merge(referrer: params[:referrer]))
              when "upload-your-file"
                Forms::BulkUploadSales::UploadYourFile.new(form_params.merge(current_user:, request:))
              when "checking-file"
                Forms::BulkUploadSales::CheckingFile.new(form_params.merge(request:))
              else
                raise "Page not found for path #{params[:id]}"
              end
  end

  def form_params
    params.fetch(:form, {}).permit(:year, :file, :organisation_id)
  end
end
