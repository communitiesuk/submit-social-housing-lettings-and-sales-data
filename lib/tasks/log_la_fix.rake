namespace :log_la_fix do
  desc "For all logs missing an LA that could have one, call the postcode changed method to request a new one from postcodes API. For logs where an LA still cannot be found, this will set them back to in progress."
  task :search_for_la_on_logs_with_nil_la, [:year] => :environment do |_task, args|
    include CollectionTimeHelper

    year = args[:year]&.to_i || current_collection_start_year

    lettings_logs = LettingsLog.filter_by_year(year).where(la: nil, needstype: 1, status: "completed")
    sales_logs = SalesLog.filter_by_year(year).where(la: nil, status: "completed")
    lettings_logs_count = lettings_logs.count
    sales_logs_count = sales_logs.count

    puts "Checking LA on #{lettings_logs_count} lettings logs in #{year}"

    i = 0
    lettings_logs.find_each do |log|
      next unless log.valid?

      log.process_postcode_changes!
      unless log.save
        puts "Failed to save lettings log #{log.id}"
        puts "Errors: #{log.errors.full_messages}"
      end

      if log.la.nil? && log.status == "in_progress"
        puts "#lettings##{log.id},\"#{log.tenancycode}\",\"#{log.propcode}\",#{log.owning_organisation_id},\"#{log.owning_organisation&.name}\",#{log.managing_organisation_id},\"#{log.managing_organisation&.name}\",#{log.assigned_to_id},\"#{log.assigned_to&.name}\",#{log.startdate},\"#{log.address_line1}\",\"#{log.address_line2}\",\"#{log.town_or_city}\",\"#{log.county}\",\"#{log.postcode_full}\",\"\",\"\""
      end

      i += 1
      if (i % 100).zero?
        puts "Processed #{i} lettings logs"
      end
    end

    puts "Done #{lettings_logs_count} lettings logs"

    puts "Checking LA on #{sales_logs_count} sales logs in #{year}"

    i = 0
    sales_logs.find_each do |log|
      next unless log.valid?

      log.process_postcode_changes!
      unless log.save
        puts "Failed to save sales log #{log.id}"
        puts "Errors: #{log.errors.full_messages}"
      end

      if log.la.nil? && log.status == "in_progress"
        puts "#sales##{log.id},\"#{log.purchid}\",#{log.owning_organisation_id},\"#{log.owning_organisation&.name}\",#{log.managing_organisation_id},\"#{log.managing_organisation&.name}\",#{log.assigned_to_id},\"#{log.assigned_to&.name}\",#{log.saledate},\"#{log.address_line1}\",\"#{log.address_line2}\",\"#{log.town_or_city}\",\"#{log.county}\",\"#{log.postcode_full}\",\"#{log.la}\""
      end

      i += 1
      if (i % 100).zero?
        puts "Processed #{i} sales logs"
      end
    end

    puts "Done #{sales_logs_count} sales logs"

    puts "Done"
  end

  desc "Parse the output of search_for_la_on_logs_with_nil_la into separate lettings and sales CSV files"
  task parse_logs_moved_to_incomplete_with_no_la: :environment do
    require "csv"

    file = "output.txt"

    lettings_headers = %w[id tenancycode propcode owning_organisation_id owning_organisation managing_organisation_id managing_organisation assigned_to_id assigned_to startdate address_line1 address_line2 town_or_city county postcode_full la_ecode la_name]
    sales_headers = %w[id purchid owning_organisation_id owning_organisation managing_organisation_id managing_organisation assigned_to_id assigned_to saledate address_line1 address_line2 town_or_city county postcode_full la_ecode la_name]

    lettings_csv = CSV.open("lettings_logs_moved_to_incomplete_with_no_la.csv", "w")
    sales_csv = CSV.open("sales_logs_moved_to_incomplete_with_no_la.csv", "w")

    lettings_csv << lettings_headers
    sales_csv << sales_headers

    File.readlines(file).each do |line|
      line = line.strip
      if line.start_with?("#lettings#")
        row = CSV.parse_line(line.delete_prefix("#lettings#"))
        lettings_csv << row
      elsif line.start_with?("#sales#")
        row = CSV.parse_line(line.delete_prefix("#sales#"))
        sales_csv << row
      end
    end

    lettings_csv.close
    sales_csv.close

    puts "Written lettings_logs_moved_to_incomplete_with_no_la.csv"
    puts "Written sales_logs_moved_to_incomplete_with_no_la.csv"
  end

  desc "Split lettings and sales CSVs by managing organisation into separate files per org"
  task split_logs_by_managing_org: :environment do
    require "csv"

    %w[lettings sales].each do |log_type|
      input_file = "#{log_type}_logs_moved_to_incomplete_with_no_la.csv"

      rows_by_org = Hash.new { |h, k| h[k] = [] }
      table = CSV.read(input_file, headers: true)

      table.each do |row|
        org_name = row["managing_organisation"]
        rows_by_org[org_name] << row
      end

      rows_by_org.each do |org_name, rows|
        if rows.size <= 30
          puts "Skipping #{org_name} (#{rows.size} rows)"
          next
        end

        FileUtils.mkdir_p("log_output")
        sanitised_name = org_name.parameterize(separator: "_")
        output_file = "log_output/#{sanitised_name}_#{log_type}_logs_moved_to_incomplete_with_no_la.csv"
        CSV.open(output_file, "w") do |csv|
          csv << table.headers
          rows.each { |row| csv << row }
        end
        puts "Written #{output_file} (#{rows.size} rows)"
      end
    end
  end
end
