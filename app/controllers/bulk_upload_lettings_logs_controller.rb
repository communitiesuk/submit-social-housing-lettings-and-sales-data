class BulkUploadLettingsLogsController < ApplicationController
  before_action :authenticate_user!

  def start
    if in_crossover_period?
      redirect_to bulk_upload_lettings_log_path(id: "year")
    else
      redirect_to bulk_upload_lettings_log_path(id: "prepare-your-file")
    end
  end

  def show
    render form.view_path
  end

  def update
    if form.valid?
      redirect_to form.next_path
    else
      render form.view_path
    end
  end

private

  def in_crossover_period?
    FormHandler.instance.forms.values.any?(&:in_crossover_period?)
  end

  def form
    @form ||= case params[:id]
              when "year"
                Forms::BulkUploadLettings::Year.new(form_params)
              when "prepare-your-file"
                Forms::BulkUploadLettings::PrepareYourFile.new(form_params)
              when "upload-your-file"
                Forms::BulkUploadLettings::UploadYourFile.new(form_params)
              else
                raise "Page not found for path #{params[:id]}"
              end
  end

  def form_params
    params.fetch(:form, {}).permit(:year)
  end
end
