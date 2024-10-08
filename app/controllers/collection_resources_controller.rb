class CollectionResourcesController < ApplicationController
  include CollectionResourcesHelper

  before_action :authenticate_user!, except: %i[download_mandatory_collection_resource]

  def index
    render_not_found unless current_user.support?

    @mandatory_lettings_collection_resources_per_year = MandatoryCollectionResourcesService.generate_resources("lettings", editable_collection_resource_years)
    @mandatory_sales_collection_resources_per_year = MandatoryCollectionResourcesService.generate_resources("sales", editable_collection_resource_years)
  end

  def download_mandatory_collection_resource
    log_type = params[:log_type]
    year = params[:year].to_i
    resource_type = params[:resource_type]

    return render_not_found unless resource_for_year_can_be_downloaded?(year)

    resource = MandatoryCollectionResourcesService.generate_resource(log_type, year, resource_type)
    return render_not_found unless resource

    download_resource(resource.download_filename)
  end

  def edit
    return render_not_found unless current_user.support?

    year = params[:year].to_i
    resource_type = params[:resource_type]
    log_type = params[:log_type]

    return render_not_found unless resource_for_year_can_be_updated?(year)

    @collection_resource = MandatoryCollectionResourcesService.generate_resource(log_type, year, resource_type)

    return render_not_found unless @collection_resource

    render "collection_resources/edit"
  end

  def update
    return render_not_found unless current_user.support?

    year = resource_params[:year].to_i
    resource_type = resource_params[:resource_type]
    log_type = resource_params[:log_type]
    file = resource_params[:file]

    return render_not_found unless resource_for_year_can_be_updated?(year)

    @collection_resource = MandatoryCollectionResourcesService.generate_resource(log_type, year, resource_type)
    render_not_found unless @collection_resource

    filename = @collection_resource.download_filename
    begin
      UploadCollectionResourcesService.upload_collection_resource(filename, file)
    rescue StandardError
      @collection_resource.errors.add(:file, "There was an error uploading this file.")
      return render "collection_resources/edit"
    end

    flash[:notice] = "The #{log_type} #{text_year_range_format(year)} #{@collection_resource.short_display_name.downcase} has been updated"
    redirect_to collection_resources_path
  end

private

  def resource_params
    params.require(:collection_resource).permit(:year, :log_type, :resource_type, :file)
  end

  def download_resource(filename, download_filename)
    file = CollectionResourcesService.new.get_file(filename)
    return render_not_found unless file

    send_data(file, disposition: "attachment", filename: download_filename)
  end

  def resource_for_year_can_be_downloaded?(year)
    return true if current_user&.support? && editable_collection_resource_years.include?(year)

    displayed_collection_resource_years.include?(year)
  end

  def resource_for_year_can_be_updated?(year)
    editable_collection_resource_years.include?(year)
  end
end
