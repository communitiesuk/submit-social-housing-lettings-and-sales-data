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
          role: role(user_field_value(xml_document, "user-type")),
          is_dpo: is_dpo?(user_field_value(xml_document, "user-type")),
          is_key_contact: is_key_contact?(user_field_value(xml_document, "contact-priority-id")),
        )
      end
    end

    def user_field_value(xml_document, field)
      field_value(xml_document, "user", field)
    end

    def role(field_value)
      return unless field_value

      {
        "co-ordinator" => "data_coordinator",
        "data provider" => "data_provider",
        "private data downloader" => "data_accessor",
      }[field_value.downcase.strip]
    end

    def is_dpo?(field_value)
      return false if field_value.blank?

      field_value.downcase.strip == "data protection officer"
    end

    def is_key_contact?(field_value)
      return false if field_value.blank?

      ["ecore contact", "key performance contact"].include?(field_value.downcase.strip)
    end
  end
end
