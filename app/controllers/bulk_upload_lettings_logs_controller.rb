class BulkUploadLettingsLogsController < ApplicationController
  before_action :authenticate_user!

  def start
    if in_crossover_period?
      redirect_to bulk_upload_lettings_log_path(id: "year")
    else
      redirect_to bulk_upload_lettings_log_path(id: "prepare-your-file", form: { year: current_year })
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

  def guidance
    @form = Forms::BulkUploadLettings::PrepareYourFile.new
    render "bulk_upload_shared/guidance"
  end

private

  def current_year
    FormHandler.instance.current_collection_start_year
  end

  def in_crossover_period?
    return true if FeatureToggle.force_crossover?

    FormHandler.instance.lettings_in_crossover_period?
  end

  def form
    @form ||= case params[:id]
              when "year"
                Forms::BulkUploadLettings::Year.new(form_params)
              when "prepare-your-file"
                Forms::BulkUploadLettings::PrepareYourFile.new(form_params)
              when "needstype"
                Forms::BulkUploadLettings::Needstype.new(form_params)
              when "upload-your-file"
                Forms::BulkUploadLettings::UploadYourFile.new(form_params.merge(current_user:))
              when "checking-file"
                Forms::BulkUploadLettings::CheckingFile.new(form_params)
              else
                raise "Page not found for path #{params[:id]}"
              end
  end

  def form_params
    params.fetch(:form, {}).permit(:year, :needstype, :file)
  end
end
