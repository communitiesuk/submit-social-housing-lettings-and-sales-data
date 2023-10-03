module Csv
  class MissingAddressesCsvService
    def initialize(organisation)
      @organisation = organisation
    end

    def create_missing_lettings_addresses_csv
      logs_with_missing_addresses = @organisation.managed_lettings_logs
      .imported
      .filter_by_year(2023)
      .where(needstype: 1, address_line1: nil, town_or_city: nil, uprn_known: [0, nil])
      .where.not(old_form_id: nil)

      logs_with_missing_town_or_city = @organisation.managed_lettings_logs
      .imported
      .filter_by_year(2023)
      .where(needstype: 1, town_or_city: nil, uprn_known: [0, nil])
      .where.not(old_form_id: nil)
      .where.not(address_line1: nil)

      logs_with_wrong_uprn = if JSON.parse(ENV["SKIP_UPRN_ISSUE_ORG_IDS"]).include?(@organisation.id)
                               []
                             else
                               @organisation.managed_lettings_logs
                                .imported
                                .filter_by_year(2023)
                                .where(needstype: 1)
                                .where.not(uprn: nil)
                                .where("uprn = propcode OR uprn = tenancycode or town_or_city = 'Bristol'")
                             end

      return if logs_with_missing_addresses.empty? && logs_with_missing_town_or_city.empty? && logs_with_wrong_uprn.empty?

      CSV.generate(headers: true) do |csv|
        csv << ["Issue type", "Lettings log ID", "Tenancy start date", "Tenant code", "Property code", "Log owner", "Owning organisation name", "Managing organisation name", "UPRN", "Address line 1", "Address line 2 (optional)", "Town or City", "County (optional)", "Postcode"]

        logs_with_missing_addresses.each do |log|
          csv << lettings_log_to_csv_row(log, "Full address required")
        end

        logs_with_missing_town_or_city.each do |log|
          csv << lettings_log_to_csv_row(log, "Missing town or city")
        end

        logs_with_wrong_uprn.each do |log|
          csv << lettings_log_to_csv_row(log, "UPRN issues")
        end
      end
    end

    def create_missing_sales_addresses_csv
      logs_with_missing_addresses = @organisation.sales_logs
      .imported
      .filter_by_year(2023)
      .where(address_line1: nil, town_or_city: nil, uprn_known: [0, nil])
      .where.not(old_form_id: nil)

      logs_with_missing_town_or_city = @organisation.sales_logs
      .imported
      .filter_by_year(2023)
      .where(town_or_city: nil, uprn_known: [0, nil])
      .where.not(old_form_id: nil)
      .where.not(address_line1: nil)

      logs_with_wrong_uprn = if JSON.parse(ENV["SKIP_UPRN_ISSUE_ORG_IDS"]).include?(@organisation.id)
                               []
                             else
                               @organisation.sales_logs
                                .imported
                                .filter_by_year(2023)
                                .where.not(uprn: nil)
                                .where("uprn = purchid or town_or_city = 'Bristol'")
                             end
      return if logs_with_missing_addresses.empty? && logs_with_missing_town_or_city.empty? && logs_with_wrong_uprn.empty?

      CSV.generate(headers: true) do |csv|
        csv << ["Issue type", "Sales log ID", "Sale completion date", "Purchaser code", "Log owner", "Owning organisation name", "UPRN", "Address line 1", "Address line 2 (optional)", "Town or City", "County (optional)", "Postcode"]

        logs_with_missing_addresses.each do |log|
          csv << sales_log_to_csv_row(log, "Full address required")
        end

        logs_with_missing_town_or_city.each do |log|
          csv << sales_log_to_csv_row(log, "Missing town or city")
        end

        logs_with_wrong_uprn.each do |log|
          csv << sales_log_to_csv_row(log, "UPRN issues")
        end
      end
    end

  private

    def sales_log_to_csv_row(log, issue_type)
      [issue_type,
       log.id,
       log.saledate&.to_date,
       log.purchid,
       log.created_by&.email,
       log.owning_organisation&.name,
       log.uprn,
       log.address_line1,
       log.address_line2,
       log.town_or_city,
       log.county,
       log.postcode_full]
    end

    def lettings_log_to_csv_row(log, issue_type)
      [issue_type,
       log.id,
       log.startdate&.to_date,
       log.tenancycode,
       log.propcode,
       log.created_by&.email,
       log.owning_organisation&.name,
       log.managing_organisation&.name,
       log.uprn,
       log.address_line1,
       log.address_line2,
       log.town_or_city,
       log.county,
       log.postcode_full]
    end
  end
end
