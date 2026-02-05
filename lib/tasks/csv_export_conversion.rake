namespace :export do
  desc "Export data to CSV"
  task csv: :environment do

    File.open("csv_export.csv", "w") do |file|
      DATA_ARRAY.each do |row|
        file.puts row.map { |val|
          if val.nil?
            "" # nil becomes empty
          else
            str = val.to_s
            if str.include?(",") || str.include?("\n") || str.include?('"')
              '"' + str.gsub('"', '""') + '"'  # quote only when needed
            else
              str
            end
          end
        }.join(",")
      end
    end

    puts "CSV exported to csv_export.csv"
  end
end

# array to convert goes here
DATA_ARRAY = []
