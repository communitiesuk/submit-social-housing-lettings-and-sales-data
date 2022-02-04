module Imports
  class UserImportService < ImportService
    def create_users(folder)
      import_from(folder, :create_user)
    end

  private

    def create_user(xml_document)
      Organisation.create!(
        old_user_id: user_field_value(xml_document, "id"),
      )
    rescue ActiveRecord::RecordNotUnique
      @logger.warn("Organisation #{name} is already present with old visible ID #{old_visible_id}, skipping.")
    end

    def user_field_value(xml_document, field)
      field_value(xml_document, "user", field)
    end
  end
end
