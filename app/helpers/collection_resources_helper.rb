module CollectionResourcesHelper
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

    file_size = number_to_human_size(metadata["Content-Length"].to_i)
    file_type = HUMAN_READABLE_CONTENT_TYPE[metadata["Content-Type"].to_sym] || "Unknown File Type"
    [file_type, file_size, file_pages].compact.join(", ")
  end
end
