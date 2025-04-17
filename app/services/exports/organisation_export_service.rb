module Exports
  class OrganisationExportService < Exports::XmlExportService
    include Exports::OrganisationExportConstants
    include CollectionTimeHelper

    def export_xml_organisations(full_update: false)
      collection = "organisations"
      recent_export = Export.organisations.order("started_at").last

      base_number = Export.organisations.where(empty_export: false).maximum(:base_number) || 1
      export = build_export_run(collection, base_number, full_update)
      archives_for_manifest = write_export_archive(export, collection, recent_export, full_update)

      export.empty_export = archives_for_manifest.empty?
      export.save!

      archives_for_manifest
    end

  private

    def get_archive_name(_year, base_number, increment)
      base_number_str = "f#{base_number.to_s.rjust(4, '0')}"
      increment_str = "inc#{increment.to_s.rjust(4, '0')}"
      "organisations_2024_2025_apr_mar_#{base_number_str}_#{increment_str}".downcase
    end

    def retrieve_resources(recent_export, full_update, _year)
      if !full_update && recent_export
        params = { from: recent_export.started_at, to: @start_time }

        Organisation
          .where(updated_at: params[:from]..params[:to])
          .or(
            Organisation.where(id: OrganisationNameChange.where(created_at: params[:from]..params[:to]).select(:organisation_id)),
          )
      else
        params = { to: @start_time }

        Organisation
          .where("updated_at <= :to", params)
          .or(
            Organisation.where(id: OrganisationNameChange.where("created_at <= :to", params).select(:organisation_id)),
          )
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
      attribute_hash["name"] = organisation.name(date: Time.zone.now)
      attribute_hash["deleted_at"] = organisation.discarded_at&.iso8601
      attribute_hash["dsa_signed"] = organisation.data_protection_confirmed?
      attribute_hash["dsa_signed_at"] = organisation.data_protection_confirmation&.signed_at&.iso8601
      attribute_hash["dpo_email"] = organisation.data_protection_confirmation&.data_protection_officer_email
      attribute_hash["provider_type"] = organisation.provider_type_before_type_cast
      attribute_hash["merge_date"] = organisation.merge_date&.iso8601
      attribute_hash["available_from"] = organisation.available_from&.iso8601
      attribute_hash["profit_status"] = nil # will need update when we add the field to the org
      attribute_hash["group"] = nil # will need update when we add the field to the org
      attribute_hash["status"] = organisation.status
      attribute_hash["active"] = attribute_hash["status"] == :active

      attribute_hash
    end
  end
end
