module CollectionResourcesHelper
  include CollectionTimeHelper

  HUMAN_READABLE_CONTENT_TYPE = { "application/pdf": "PDF",
                                  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": "Microsoft Excel",
                                  "application/vnd.ms-excel": "Microsoft Excel (Old Format)",
                                  "application/msword": "Microsoft Word",
                                  "application/vnd.openxmlformats-officedocument.wordprocessingml.document": "Microsoft Word (DOCX)",
                                  "image/jpeg": "JPEG Image",
                                  "image/png": "PNG Image",
                                  "text/plain": "Text Document",
                                  "text/html": "HTML Document" }.freeze

  def file_type_size_and_pages(file, number_of_pages: nil)
    file_pages = number_of_pages ? pluralize(number_of_pages, "page") : nil
    metadata = CollectionResourcesService.new.get_file_metadata(file)

    return [file_pages].compact.join(", ") unless metadata

    file_size = number_to_human_size(metadata["content_length"].to_i)
    file_type = HUMAN_READABLE_CONTENT_TYPE[metadata["content_type"].to_sym] || "Unknown File Type"
    [file_type, file_size, file_pages].compact.join(", ")
  end

  def displayed_collection_resource_years
    return [previous_collection_start_year, current_collection_start_year] if FormHandler.instance.in_edit_crossover_period?

    [current_collection_start_year]
  end

  def editable_collection_resource_years
    return [previous_collection_start_year, current_collection_start_year] if FormHandler.instance.in_edit_crossover_period?
    return [current_collection_start_year, next_collection_start_year] if Time.zone.today >= Time.zone.local(Time.zone.today.year, 1, 1) && Time.zone.today < Time.zone.local(Time.zone.today.year, 4, 1)

    [current_collection_start_year]
  end

  def year_range_format(year)
    "#{year % 100}/#{(year + 1) % 100}"
  end

  def text_year_range_format(year)
    "#{year} to #{year + 1}"
  end

  def underscored_file_year_format(year)
    "#{year}_#{(year + 1) % 100}"
  end

  def dasherised_file_year_format(year)
    underscored_file_year_format(year).dasherize
  end

  def short_underscored_year_range_format(year)
    "#{year % 100}_#{(year + 1) % 100}"
  end

  def document_list_component_items(resources)
    resources.map do |resource|
      {
        name: "Download the #{resource.display_name}",
        href: send(resource.download_path),
        metadata: file_type_size_and_pages(resource.download_filename),
      }
    end
  end

  def document_list_edit_component_items(resources)
    resources.map do |resource|
      {
        name: resource.download_filename,
        href: send(resource.download_path),
        metadata: file_type_size_and_pages(resource.download_filename),
      }
    end
  end
end
