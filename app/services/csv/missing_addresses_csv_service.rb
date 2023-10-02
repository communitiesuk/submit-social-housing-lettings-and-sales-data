module Csv
  class MissingAddressesCsvService
    def initialize(organisation)
      @organisation = organisation
    end

    def create_missing_lettings_addresses_csv
      logs_with_missing_addresses = @organisation.managed_lettings_logs.imported.filter_by_year(2023).where(needstype: 1, address_line1: nil, town_or_city: nil, uprn_known: [0, nil]).where.not(old_form_id: nil)
      return if logs_with_missing_addresses.empty?

      generate_missing_lettings_addresses_csv(logs_with_missing_addresses)
    end

    def create_missing_sales_addresses_csv
      logs_with_missing_addresses = @organisation.sales_logs.imported.filter_by_year(2023).where(address_line1: nil, town_or_city: nil, uprn_known: [0, nil]).where.not(old_form_id: nil)
      return if logs_with_missing_addresses.empty?

      generate_missing_sales_addresses_csv(logs_with_missing_addresses)
    end

    def create_missing_lettings_town_or_city_csv
      logs_with_missing_town_or_city = @organisation.managed_lettings_logs.imported.filter_by_year(2023).where(needstype: 1, town_or_city: nil, uprn_known: [0, nil]).where.not(old_form_id: nil).where.not(address_line1: nil)
      return if logs_with_missing_town_or_city.empty?

      generate_missing_lettings_addresses_csv(logs_with_missing_town_or_city)
    end

    def create_missing_sales_town_or_city_csv
      logs_with_missing_town_or_city = @organisation.sales_logs.imported.filter_by_year(2023).where(town_or_city: nil, uprn_known: [0, nil]).where.not(old_form_id: nil).where.not(address_line1: nil)
      return if logs_with_missing_town_or_city.empty?

      generate_missing_sales_addresses_csv(logs_with_missing_town_or_city)
    end

  private

    def generate_missing_lettings_addresses_csv(logs)
      CSV.generate(headers: true) do |csv|
        csv << ["Lettings log ID", "Tenancy start date", "Tenant code", "Property code", "Log owner", "Owning organisation name", "Managing organisation name", "Address line 1", "Address line 2", "Town or City", "County", "Postcode", "Local authority"]

        logs.each do |log|
          csv << [log.id,
                  log.startdate&.to_date,
                  log.tenancycode,
                  log.propcode,
                  log.created_by&.email,
                  log.owning_organisation&.name,
                  log.managing_organisation&.name,
                  log.address_line1,
                  log.address_line2,
                  log.town_or_city,
                  log.county,
                  log.postcode_full,
                  log.la]
        end
      end
    end

    def generate_missing_sales_addresses_csv(logs)
      CSV.generate(headers: true) do |csv|
        csv << ["Sales log ID", "Sale completion date", "Purchaser code", "Log owner", "Owning organisation name", "Address line 1", "Address line 2", "Town or City", "County", "Postcode", "Local authority"]

        logs.each do |log|
          csv << [log.id,
                  log.saledate&.to_date,
                  log.purchid,
                  log.created_by&.email,
                  log.owning_organisation&.name,
                  log.address_line1,
                  log.address_line2,
                  log.town_or_city,
                  log.county,
                  log.postcode_full,
                  log.la]
        end
      end
    end
  end
end
