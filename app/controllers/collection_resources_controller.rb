class CollectionResourcesController < ApplicationController
  include CollectionResourcesHelper

  before_action :authenticate_user!, except: %i[download_mandatory_collection_resource download_additional_collection_resource]

  def index
    render_not_found unless current_user.support?

    @mandatory_lettings_collection_resources_per_year = MandatoryCollectionResourcesService.generate_resources("lettings", editable_collection_resource_years)
    @mandatory_sales_collection_resources_per_year = MandatoryCollectionResourcesService.generate_resources("sales", editable_collection_resource_years)
    @additional_lettings_collection_resources_per_year = CollectionResource.where(log_type: "lettings", mandatory: false).group_by(&:year)
    @additional_sales_collection_resources_per_year = CollectionResource.where(log_type: "sales", mandatory: false).group_by(&:year)
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

  def download_additional_collection_resource
    resource = CollectionResource.find_by(id: params[:collection_resource_id])

    return render_not_found unless resource
    return render_not_found unless resource_for_year_can_be_downloaded?(resource.year)

    download_resource(resource.download_filename)
  end

  def edit_mandatory_collection_resource
    return render_not_found unless current_user.support?

    year = params[:year].to_i
    resource_type = params[:resource_type]
    log_type = params[:log_type]

    return render_not_found unless resource_for_year_can_be_updated?(year)

    @collection_resource = MandatoryCollectionResourcesService.generate_resource(log_type, year, resource_type)

    return render_not_found unless @collection_resource

    render "collection_resources/edit"
  end

  def edit_additional_collection_resource
    return render_not_found unless current_user.support?

    @collection_resource = CollectionResource.find_by(id: params[:collection_resource_id])

    return render_not_found unless @collection_resource
    return render_not_found unless resource_for_year_can_be_updated?(@collection_resource.year)

    render "collection_resources/edit"
  end

  def update_mandatory_collection_resource
    return render_not_found unless current_user.support?

    year = resource_params[:year].to_i
    resource_type = resource_params[:resource_type]
    log_type = resource_params[:log_type]
    file = resource_params[:file]

    return render_not_found unless resource_for_year_can_be_updated?(year)

    @collection_resource = MandatoryCollectionResourcesService.generate_resource(log_type, year, resource_type)
    render_not_found unless @collection_resource

    @collection_resource.file = file
    @collection_resource.validate_attached_file

    return render "collection_resources/edit" if @collection_resource.errors.any?

    filename = @collection_resource.download_filename
    begin
      CollectionResourcesService.new.upload_collection_resource(filename, file)
    rescue StandardError
      @collection_resource.errors.add(:file, :error_uploading)
      return render "collection_resources/edit"
    end

    flash[:notice] = "The #{log_type} #{text_year_range_format(year)} #{@collection_resource.short_display_name.downcase} has been updated"
    redirect_to collection_resources_path
  end

  def update_additional_collection_resource
    return render_not_found unless current_user.support?

    @collection_resource = CollectionResource.find_by(id: params[:collection_resource_id])

    return render_not_found unless @collection_resource
    return render_not_found unless resource_for_year_can_be_updated?(@collection_resource.year)

    @collection_resource.file = resource_params[:file]
    @collection_resource.validate_attached_file
    return render "collection_resources/edit" if @collection_resource.errors.any?

    @collection_resource.short_display_name = resource_params[:short_display_name]
    @collection_resource.download_filename = @collection_resource.file&.original_filename
    @collection_resource.display_name = "#{@collection_resource.log_type} #{@collection_resource.short_display_name} (#{text_year_range_format(@collection_resource.year)})"
    if @collection_resource.save
      begin
        CollectionResourcesService.new.upload_collection_resource(@collection_resource.download_filename, @collection_resource.file)
        flash[:notice] = "The #{@collection_resource.log_type} #{text_year_range_format(@collection_resource.year)} #{@collection_resource.short_display_name.downcase} has been updated."
        redirect_to collection_resources_path
      rescue StandardError
        @collection_resource.errors.add(:file, :error_uploading)
        render "collection_resources/edit"
      end
    else
      render "collection_resources/edit"
    end
  end

  def confirm_mandatory_collection_resources_release
    return render_not_found unless current_user.support?

    @year = params[:year].to_i

    return render_not_found unless editable_collection_resource_years.include?(@year)

    render "collection_resources/confirm_mandatory_collection_resources_release"
  end

  def release_mandatory_collection_resources
    return render_not_found unless current_user.support?

    year = params[:year].to_i

    return render_not_found unless editable_collection_resource_years.include?(year)

    MandatoryCollectionResourcesService.release_resources(year)

    flash[:notice] = "The #{text_year_range_format(year)} collection resources are now available to users."
    redirect_to collection_resources_path
  end

  def new
    return render_not_found unless current_user.support?

    year = params[:year].to_i
    log_type = params[:log_type]

    return render_not_found unless editable_collection_resource_years.include?(year)

    @collection_resource = CollectionResource.new(year:, log_type:)
  end

  def create
    return render_not_found unless current_user.support? && editable_collection_resource_years.include?(resource_params[:year].to_i)

    @collection_resource = CollectionResource.new(resource_params)
    @collection_resource.download_filename ||= @collection_resource.file&.original_filename
    @collection_resource.display_name = "#{@collection_resource.log_type} #{@collection_resource.short_display_name} (#{text_year_range_format(@collection_resource.year)})"

    @collection_resource.validate_attached_file
    return render "collection_resources/new" if @collection_resource.errors.any?

    if @collection_resource.save
      begin
        CollectionResourcesService.new.upload_collection_resource(@collection_resource.download_filename, @collection_resource.file)
        flash[:notice] = "The #{@collection_resource.log_type} #{text_year_range_format(@collection_resource.year)} #{@collection_resource.short_display_name} is now available to users."
        redirect_to collection_resources_path
      rescue StandardError
        @collection_resource.errors.add(:file, :error_uploading)
        render "collection_resources/new"
      end
    else
      render "collection_resources/new"
    end
  end

private

  def resource_params
    params.require(:collection_resource).permit(:year, :log_type, :resource_type, :file, :mandatory, :short_display_name)
  end

  def download_resource(filename)
    file = CollectionResourcesService.new.get_file(filename)
    return render_not_found unless file

    send_data(file, disposition: "attachment", filename:)
  end

  def resource_for_year_can_be_downloaded?(year)
    return true if current_user&.support? && editable_collection_resource_years.include?(year)

    displayed_collection_resource_years.include?(year)
  end

  def resource_for_year_can_be_updated?(year)
    editable_collection_resource_years.include?(year)
  end
end
