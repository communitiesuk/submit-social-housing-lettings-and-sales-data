module Imports
  class SchemeLocationImportService < ImportService
    def create_scheme_locations(folder)
      import_from(folder, :create_scheme_location)
    end

    def create_scheme_location(xml_document)
      attributes = scheme_attributes(xml_document)
      schemes = Scheme.where(old_id: attributes["scheme_old_id"])
      raise "Scheme not found with legacy ID #{attributes["scheme_old_id"]}" if schemes.empty?

      if schemes.size == 1 && schemes.first.locations&.empty?
        scheme = update_scheme(schemes.first, attributes)
      else
        scheme = find_scheme_to_merge(attributes)
        scheme ||= duplicate_scheme(schemes, attributes)
      end
      add_location(scheme, attributes)
    end

  private

    REGISTERED_UNDER_CARE_ACT = {
      2 => "(Part-registered care home)",
      3 => "(Registered personal care home)",
      4 => "(Registered nursing care home)",
    }.freeze

    def create_scheme(source_scheme, attributes)
      Scheme.create!(
        scheme_type: attributes["scheme_type"],
        registered_under_care_act: attributes["registered_under_care_act"],
        support_type: attributes["support_type"],
        intended_stay: attributes["intended_stay"],
        primary_client_group: attributes["primary_client_group"],
        secondary_client_group: attributes["secondary_client_group"],
        sensitive: attributes["sensitive"],
        end_date: attributes["end_date"],
        # These values were set by the scheme import (management groups)
        owning_organisation_id: source_scheme.owning_organisation_id,
        managing_organisation_id: source_scheme.managing_organisation_id,
        service_name: source_scheme.service_name,
        arrangement_type: source_scheme.arrangement_type,
        old_id: source_scheme.old_id,
        old_visible_id: source_scheme.old_visible_id,
      )
    end

    def update_scheme(scheme, attributes)
      scheme.update!(
        scheme_type: attributes["scheme_type"],
        registered_under_care_act: attributes["registered_under_care_act"],
        support_type: attributes["support_type"],
        intended_stay: attributes["intended_stay"],
        primary_client_group: attributes["primary_client_group"],
        secondary_client_group: attributes["secondary_client_group"],
        sensitive: attributes["sensitive"],
        end_date: attributes["end_date"]
      )
      scheme
    end

    def scheme_attributes(xml_doc)
      attributes = {}
      attributes["scheme_type"] = safe_string_as_integer(xml_doc, "scheme-type")
      registered_under_care_act = safe_string_as_integer(xml_doc, "reg-home-type")
      attributes["registered_under_care_act"] = registered_under_care_act.zero? ? nil : registered_under_care_act
      attributes["support_type"] = safe_string_as_integer(xml_doc, "support-type")
      attributes["intended_stay"] = string_or_nil(xml_doc, "intended-stay")
      attributes["primary_client_group"] = string_or_nil(xml_doc, "client-group-1")
      attributes["secondary_client_group"] = string_or_nil(xml_doc, "client-group-2")
      attributes["secondary_client_group"] = nil if attributes["primary_client_group"] == attributes["secondary_client_group"]
      attributes["sensitive"] = sensitive(xml_doc)
      attributes["end_date"] = parse_end_date(xml_doc)
      attributes["location_name"] = string_or_nil(xml_doc, "name")
      attributes["postcode"] = string_or_nil(xml_doc, "postcode")
      attributes["units"] = safe_string_as_integer(xml_doc, "total-units")
      attributes["type_of_unit"] = safe_string_as_integer(xml_doc, "unit-type")
      attributes["location_old_id"] = string_or_nil(xml_doc, "id")
      attributes["location_old_visible_id"] = safe_string_as_integer(xml_doc, "visible-id")
      attributes["scheme_old_id"] = string_or_nil(xml_doc, "mgmtgroup")
      attributes
    end

    def add_location(scheme, attributes)
      if attributes["end_date"].nil? || attributes["end_date"] >= Time.zone.now
        # wheelchair_adaptation: string_or_nil(xml_doc, "mobility-type"),
        begin
          Location.create!(
            name: attributes["location_name"],
            postcode: attributes["postcode"],
            units: attributes["units"],
            type_of_unit: attributes["type_of_unit"],
            old_visible_id: attributes["location_old_visible_id"],
            old_id: attributes["location_old_id"],
            scheme: scheme,
          )
        rescue ActiveRecord::RecordNotUnique
          @logger.warn("Location is already present with legacy ID #{attributes["location_old_id"]}, skipping")
        end
      else
        @logger.warn("Location with legacy ID #{attributes["location_old_id"]} is expired (#{attributes["end_date"]}), skipping")
      end
    end

    def find_scheme_to_merge(attributes)
      Scheme.find_by(
        old_id: attributes["scheme_old_id"],
        scheme_type: attributes["scheme_type"],
        registered_under_care_act: attributes["registered_under_care_act"],
        support_type: attributes["support_type"],
        intended_stay: attributes["intended_stay"],
        primary_client_group: attributes["primary_client_group"],
        secondary_client_group: attributes["secondary_client_group"],
      )
    end

    def duplicate_scheme(schemes, attributes)
      # Since all schemes in the array are different, pick the first one
      # In the future, consider a better selection method if needed
      old_scheme = schemes.first
      new_scheme = create_scheme(old_scheme, attributes)

      if old_scheme.scheme_type != new_scheme.scheme_type
        rename_schemes(old_scheme, new_scheme, :scheme_type)
      elsif old_scheme.registered_under_care_act != new_scheme.registered_under_care_act
        rename_registered_care(old_scheme, new_scheme)
      elsif old_scheme.support_type != new_scheme.support_type
        rename_schemes(old_scheme, new_scheme, :support_type)
      elsif old_scheme.intended_stay != new_scheme.intended_stay
        rename_schemes(old_scheme, new_scheme, :intended_stay)
      elsif old_scheme.primary_client_group != new_scheme.primary_client_group
        rename_schemes(old_scheme, new_scheme, :primary_client_group)
      elsif old_scheme.secondary_client_group != new_scheme.secondary_client_group
        rename_schemes(old_scheme, new_scheme, :secondary_client_group)
      end

      new_scheme
    end

    def rename_registered_care(*schemes)
      schemes.each do |scheme|
        if REGISTERED_UNDER_CARE_ACT.key?(scheme.registered_under_care_act_before_type_cast)
          suffix = REGISTERED_UNDER_CARE_ACT[scheme.registered_under_care_act_before_type_cast]
          scheme.update!(service_name: "#{scheme.service_name} - #{suffix}")
        end
      end
    end

    def rename_schemes(old_scheme, new_scheme, attribute)
      old_scheme_attribute = old_scheme.send(attribute)
      new_scheme_attribute = new_scheme.send(attribute)

      if old_scheme_attribute
        old_scheme_name = "#{old_scheme.service_name} - #{old_scheme_attribute}"
        old_scheme.update!(service_name: old_scheme_name)
      end
      if new_scheme_attribute
        new_scheme_name = "#{new_scheme.service_name} - #{new_scheme_attribute}"
        new_scheme.update!(service_name: new_scheme_name)
      end
    end

    def location_field_value(xml_doc, field)
      field_value(xml_doc, "scheme", field)
    end

    def string_or_nil(xml_doc, attribute)
      str = location_field_value(xml_doc, attribute)
      str.presence
    end

    # Safe: A string that represents only an integer (or empty/nil)
    def safe_string_as_integer(xml_doc, attribute)
      str = location_field_value(xml_doc, attribute)
      Integer(str, exception: false)
    end

    def sensitive(xml_doc)
      value = string_or_nil(xml_doc, "sensitive")
      if value == "true"
        1
      else
        0
      end
    end

    def parse_end_date(xml_doc)
      end_date = string_or_nil(xml_doc, "end-date")
      Time.zone.parse(end_date) if end_date
    end
  end
end
