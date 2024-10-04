class MandatoryCollectionResourcesService
  MANDATORY_RESOURCES = %w[paper_form bulk_upload_template bulk_upload_specification].freeze

  def self.generate_resources(log_type, collection_years)
    mandatory_resources_per_year = {}
    collection_years.map do |year|
      mandatory_resources_per_year[year] = resources_per_year(year, log_type)
    end
    mandatory_resources_per_year
  end

  def self.resources_per_year(year, log_type)
    MANDATORY_RESOURCES.map do |resource|
      generate_resource(log_type, year, resource)
    end
  end

  def self.generate_resource(log_type, year, resource_type)
    return unless MANDATORY_RESOURCES.include?(resource_type)

    CollectionResource.new(
      resource_type:,
      display_name: display_name(resource_type, year, log_type),
      short_display_name: resource_type.humanize,
      year:,
      log_type:,
      download_filename: download_filename(resource_type, year, log_type),
    )
  end

  def self.display_name(resource, year, log_type)
    year_range = "#{year} to #{year + 1}"
    case resource
    when "paper_form"
      "#{log_type} log for tenants (#{year_range})"
    when "bulk_upload_template"
      "#{log_type} bulk upload template (#{year_range})"
    when "bulk_upload_specification"
      "#{log_type} bulk upload specification (#{year_range})"
    end
  end

  def self.download_filename(resource, year, log_type)
    year_range = "#{year}_#{(year + 1) % 100}"
    case resource
    when "paper_form"
      "#{year_range}_#{log_type}_paper_form.pdf"
    when "bulk_upload_template"
      "bulk-upload-#{log_type}-template-#{year_range.dasherize}.xlsx"
    when "bulk_upload_specification"
      "bulk-upload-#{log_type}-specification-#{year_range.dasherize}.xlsx"
    end
  end
end
