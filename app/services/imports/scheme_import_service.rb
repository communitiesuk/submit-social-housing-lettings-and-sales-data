module Imports
  class SchemeImportService < ImportService
    def create_schemes(folder)
      import_from(folder, :create_scheme)
    end

  private

    def create_scheme(xml_document)
      old_visible_id = scheme_field_value(xml_document, "visible-id")
      Scheme.create!(
        old_id: scheme_field_value(xml_document, "id"),
        old_visible_id:
      )
    rescue ActiveRecord::RecordNotUnique
      name = scheme_field_value(xml_document, "name")
      @logger.warn("Scheme #{name} is already present with old visible ID #{old_visible_id}, skipping.")
    end

    def scheme_field_value(xml_document, field)
      field_value(xml_document, "mgmtgroup", field)
    end
  end
end
