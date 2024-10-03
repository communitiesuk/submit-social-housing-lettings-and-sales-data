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
    url = "https://#{Rails.application.config.collection_resources_s3_bucket_name}.s3.amazonaws.com/#{file}"
    uri = URI.parse(url)

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request_head(uri)
    end
    return [file_pages].compact.join(", ") unless response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)

    file_size = number_to_human_size(response["Content-Length"].to_i)
    file_type = HUMAN_READABLE_CONTENT_TYPE[response["Content-Type"].to_sym] || "Unknown File Type"
    [file_type, file_size, file_pages].compact.join(", ")
  end
end
