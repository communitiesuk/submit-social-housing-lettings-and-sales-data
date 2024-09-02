module Exports
  class OrganisationExportService < Exports::XmlExportService
    include Exports::OrganisationExportConstants
    include CollectionTimeHelper

    def export_xml_organisations(full_update: false)
      recent_export = Export.order("started_at").last

      collection = "organisations"
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
        Organisation.where("(updated_at >= :from AND updated_at <= :to)", params)
      else
        params = { to: @start_time }
        Organisation.where("updated_at <= :to", params)
      end
    end

    def build_export_xml(organisations)
      doc = Nokogiri::XML("<forms/>")

      organisations.each do |organisation|
        attribute_hash = apply_cds_transformation(organisation)
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

    def apply_cds_transformation(organisation)
      attribute_hash = organisation.attributes
      attribute_hash["deleted_at"] = organisation.discarded_at
      attribute_hash["dsa_signed"] = organisation.data_protection_confirmed?
      attribute_hash["dsa_signed_at"] = organisation.data_protection_confirmation&.signed_at
      attribute_hash["dpo_email"] = organisation.data_protection_confirmation&.data_protection_officer_email

      attribute_hash
    end
  end
end
