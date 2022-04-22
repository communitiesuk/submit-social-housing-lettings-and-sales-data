module Imports
  class ImportService
  private

    def initialize(storage_service, logger = Rails.logger)
      @storage_service = storage_service
      @logger = logger
    end

    def import_from(folder, create_method)
      filenames = @storage_service.list_files(folder)
      filenames.each do |filename|
        file_io = @storage_service.get_file_io(filename)
        xml_document = Nokogiri::XML(file_io)
        send(create_method, xml_document)
      rescue StandardError => e
        @logger.error "#{e.class} in #{filename}: #{e.message}"
      end
    end

    def field_value(xml_document, namespace, field)
      xml_document.at_xpath("//#{namespace}:#{field}")&.text
    end

    def to_boolean(input_string)
      input_string == "true"
    end
  end
end
