module Imports
  class ImportService
    include Imports::ImportUtils

    private

    def initialize(storage_service, logger = Rails.logger)
      @storage_service = storage_service
      @logger = logger
      @logs_with_discrepancies = []
    end

    def import_from(folder, create_method)
      filenames = @storage_service.list_files(folder)
      filenames.each do |filename|
        file_io = @storage_service.get_file_io(filename)
        xml_document = Nokogiri::XML(file_io)
        send(create_method, xml_document)
      rescue StandardError => e
        @logger.error "#{e.class} in #{filename}: #{e.message}. Caller: #{e.backtrace.first}"
      end
    end
  end
end
