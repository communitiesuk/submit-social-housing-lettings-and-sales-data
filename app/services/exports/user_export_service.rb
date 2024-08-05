module Exports
  class UserExportService < Exports::XmlExportService
    include Exports::UserExportConstants
    include CollectionTimeHelper

    def initialize(storage_service, start_time, logger = Rails.logger)
      @storage_service = storage_service
      @logger = logger
      @start_time = start_time
    end

    def export_xml_users(full_update: false)
      recent_export = Export.order("started_at").last

      collection = "users"
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
      "core_#{collection}_#{base_number_str}_#{increment_str}".downcase
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
      attribute_hash
    end
  end
end
