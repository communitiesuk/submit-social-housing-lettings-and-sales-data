module Exports
  class UserExportService < Exports::XmlExportService
    include Exports::UserExportConstants
    include CollectionTimeHelper

    def export_xml_users(full_update: false)
      collection = "users"
      recent_export = Export.where(collection:).order("started_at").last

      base_number = Export.where(empty_export: false, collection:).maximum(:base_number) || 1
      export = build_export_run(collection, base_number, full_update)
      archives_for_manifest = write_export_archive(export, collection, recent_export, full_update)

      export.empty_export = archives_for_manifest.empty?
      export.save!

      archives_for_manifest
    end

  private

    def get_archive_name(collection, base_number, increment)
      return unless collection

      base_number_str = "f#{base_number.to_s.rjust(4, '0')}"
      increment_str = "inc#{increment.to_s.rjust(4, '0')}"
      "#{collection}_2024_2025_apr_mar_#{base_number_str}_#{increment_str}".downcase
    end

    def retrieve_resources(recent_export, full_update, _collection)
      if !full_update && recent_export
        params = { from: recent_export.started_at, to: @start_time }
        User.where("(updated_at >= :from AND updated_at <= :to)", params)
      else
        params = { to: @start_time }
        User.where("updated_at <= :to", params)
      end
    end

    def build_export_xml(users)
      doc = Nokogiri::XML("<forms/>")

      users.each do |user|
        attribute_hash = apply_cds_transformation(user)
        form = doc.create_element("form")
        doc.at("forms") << form
        attribute_hash.each do |key, value|
          if !EXPORT_FIELDS.include?(key)
            next
          else
            form << doc.create_element(key, value)
          end
        end
      end

      xml_doc_to_temp_file(doc)
    end

    def apply_cds_transformation(user)
      attribute_hash = user.attributes_before_type_cast
      attribute_hash["role"] = user.role
      attribute_hash["organisation_name"] = user.organisation.name
      attribute_hash["active"] = user.active?
      attribute_hash["phone"] = [user.phone, user.phone_extension].compact.join(" ")
      attribute_hash
    end
  end
end
