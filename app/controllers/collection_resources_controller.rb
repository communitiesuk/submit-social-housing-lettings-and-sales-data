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

    validate_file(file)

    return render "collection_resources/edit" if @collection_resource.errors.any?

    filename = @collection_resource.download_filename
    begin
      UploadCollectionResourcesService.upload_collection_resource(filename, file)
    rescue StandardError
      @collection_resource.errors.add(:file, :error_uploading)
      return render "collection_resources/edit"
    end

    flash[:notice] = "The #{log_type} #{text_year_range_format(year)} #{@collection_resource.short_display_name.downcase} has been updated"
    redirect_to collection_resources_path
  end

private

  def resource_params
    params.require(:collection_resource).permit(:year, :log_type, :resource_type, :file)
  end

  def download_resource(filename)
    url = "https://#{Rails.application.config.collection_resources_s3_bucket_name}.s3.amazonaws.com/#{filename}"
    uri = URI.parse(url)

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new(uri)
      http.request(request)
    end

    if response.is_a?(Net::HTTPSuccess)
      send_data(response.body, disposition: "attachment", filename:)
    else
      render_not_found
    end
  end

  def resource_for_year_can_be_downloaded?(year)
    return true if current_user&.support? && editable_collection_resource_years.include?(year)

    displayed_collection_resource_years.include?(year)
  end

  def resource_for_year_can_be_updated?(year)
    editable_collection_resource_years.include?(year)
  end

  def validate_file(file)
    return @collection_resource.errors.add(:file, :blank) unless file
    return @collection_resource.errors.add(:file, :above_100_mb) if file.size > 100.megabytes

    argv = %W[file --brief --mime-type -- #{file.path}]
    output = `#{argv.shelljoin}`

    case @collection_resource.resource_type
    when "paper_form"
      unless output.match?(/application\/pdf/)
        @collection_resource.errors.add(:file, :must_be_pdf)
      end
    when "bulk_upload_template", "bulk_upload_specification"
      unless output.match?(/application\/vnd\.ms-excel|application\/vnd\.openxmlformats-officedocument\.spreadsheetml\.sheet/)
        @collection_resource.errors.add(:file, :must_be_xlsx, resource: @collection_resource.short_display_name.downcase)
      end
    end
  end
end
