module CollectionResourcesHelper
  def file_type_size_and_pages(file, number_of_pages: nil)
    extension_mapping = {
      "xlsx" => "Microsoft Excel",
      "pdf" => "PDF",
    }
    extension = File.extname(file)[1..]

    file_type = extension_mapping.fetch(extension, extension)

    file_size = number_to_human_size(File.size("public/files/#{file}"), precision: 0, significant: false)
    file_pages = number_of_pages ? pluralize(number_of_pages, "page") : nil
    [file_type, file_size, file_pages].compact.join(", ")
  end
end
