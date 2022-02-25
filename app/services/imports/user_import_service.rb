module Imports
  class UserImportService < ImportService
    def create_users(folder)
      import_from(folder, :create_user)
    end

  private

    PROVIDER_TYPE = {
      "Data Provider" => User.roles[:data_provider],
    }.freeze

    def create_user(xml_document)
      organisation = Organisation.find_by(old_org_id: user_field_value(xml_document, "institution"))
      old_user_id = user_field_value(xml_document, "id")
      name = user_field_value(xml_document, "full-name")
      if User.find_by(old_user_id:, organisation:)
        @logger.warn("User #{name} with old user id #{old_user_id} is already present, skipping.")
      else
        User.create!(
          email: user_field_value(xml_document, "user-name"),
          name:,
          password: Devise.friendly_token,
          phone: user_field_value(xml_document, "telephone-no"),
          old_user_id:,
          organisation:,
          role: PROVIDER_TYPE[user_field_value(xml_document, "user-type")],
        )
      end
    end

    def user_field_value(xml_document, field)
      field_value(xml_document, "user", field)
    end
  end
end
