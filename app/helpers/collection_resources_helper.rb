module CollectionResourcesHelper
  def metadata_helper(file, pages = nil)
    extension = file.split(".")[-1]
    type_string = case extension
                  when "xlsx" then "Microsoft Excel"
                  when "pdf" then "PDF"
                  else extension
                  end
    size = number_to_human_size(File.size("public/files/#{file}"), precision: 0, significant: false)
    pages_string = pages.present? ? pluralize(pages, "page") : nil
    [type_string, size, pages_string].compact.join(", ")
  end
end
