module Imports
  class SchemeLocationImportService < ImportService
    def create_scheme_locations(folder)
      import_from(folder, :create_scheme_location)
    end

  private

    def create_scheme_location(xml_document)
      old_visible_id = location_field_value(xml_document, "visible-id")
      Scheme.create!(
        old_id: location_field_value(xml_document, "id"),
        old_visible_id:
      )
    rescue ActiveRecord::RecordNotUnique
      name = location_field_value(xml_document, "name")
      @logger.warn("Location #{name} is already present with old visible ID #{old_visible_id}, skipping.")
    end

    def location_field_value(xml_document, field)
      field_value(xml_document, "scheme", field)
    end
  end
end
