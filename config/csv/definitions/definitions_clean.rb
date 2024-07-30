require "csv"
require "tempfile"
require "fileutils"

DIRECTORY = "config/csv/definitions"
ORIGINAL_DIRECTORY = File.join(DIRECTORY, "original")
FORMATTED_DIRECTORY = File.join(DIRECTORY, "formatted")
CLEANED_DIRECTORY = File.join(DIRECTORY, "cleaned")
DELIMITER = ","
REPLACEMENT_CHAR = ";"

# Common errors that are found in the CSV files have the invalid character '�' replaced with the correct character or removed
COMMON_ERRORS = {
  "tenant�s" => "'",
  "Don�t" => "'",
  "household�s" => "'",
  "buyer�s" => "'",
  "3�s" => "'",
  "4�s" => "'",
  "5�s" => "'",
  "6�s" => "'",
  "a �local" => "",
  "postcode�" => "",
  "confirmed: �You" => "",
  "given �reasonable" => "",
  "preference� by" => "",
  "confirmed: �Are" => "",
  "postcode�,,," => "",
  "expect.�"  => "",
  "is %{age}.�" => "",
  "agreement�?" => "",
}
def clean_csv_file(file)
  original_path = File.join(ORIGINAL_DIRECTORY, file)
  content = File.read(original_path).encode("UTF-8", invalid: :replace, undef: :replace, replace: '�')

  updated_content = ""
  content.each_line do |line|
    # Replace common errors
    if line.include?("�")
      COMMON_ERRORS.each do |error, correction|
        error_regex = Regexp.new(error.gsub('�', '\�'))
        if line =~ error_regex
          line.gsub!('�', correction)
        end
      end
    end

    # Replace uncommon errors with user input
    if line.include?("�")
      puts "Line with unrecognised symbol: #{line}"
      line.chars.each_with_index do |char, index|
        if char == "�"
          first_before_space = line.rindex(' ', index - 1) || 0
          before_space = line.rindex(' ', first_before_space - 1) || first_before_space
          first_after_space = line.index(' ', index + 1) || line.length
          after_space = line.index(' ', first_after_space + 1) || line.length
          before_word = line[before_space...index].strip
          after_word = line[index+1..after_space].strip

          context = if index == line.length - 1
                      "#{before_word}�"
                    else
                      "#{before_word} �#{after_word}"
                    end

          puts "Context: '#{context}'. Choose a replacement for '�':"
          puts "1. Blank (just remove)"
          puts "2. ' (single quote)"
          puts "3. Space"
          puts "Type your choice or enter a replacement:"
          choice = STDIN.gets.chomp
          replacement = case choice
                        when "1"
                          ""
                        when "2"
                          "'"
                        when "3"
                          " "
                        else
                          choice
                        end
          line[index] = replacement
        end
      end
    end

    # if line.count(",") > 1
    #   first_comma_index = line.index(",")
    #   line = line[0..first_comma_index] + line[(first_comma_index + 1)..-1].gsub(",", REPLACEMENT_CHAR)
    # end

    updated_content << line
  end


  temp_file = Tempfile.new
  temp_file.write(updated_content)
  temp_file.close

  temp_file.path
end

FileUtils.mkdir_p(FORMATTED_DIRECTORY)
FileUtils.mkdir_p(CLEANED_DIRECTORY)

# filenames = %w[lettings_support_download_23_24.csv lettings_support_download_24_25.csv lettings_user_download_23_24.csv lettings_user_download_24_25.csv sales_support_download_23_24.csv sales_support_download_24_25.csv sales_user_download_23_24.csv sales_user_download_24_25.csv]
filenames = Dir.entries(ORIGINAL_DIRECTORY).select { |f| File.extname(f) == ".csv" }

filenames.each do |filename|
  cleaned_file_path = clean_csv_file(filename)

  first_values = []
  second_values = []

  CSV.foreach(cleaned_file_path) do |row|
    first_values << row[0] unless row[0].nil?
    second_values << row[1] unless row[1].nil?
  end

  puts "File #{filename} has been cleaned"
  puts "First values (count): #{first_values.count}"
  puts "Second values (count): #{second_values.count}"

  output_csv_path = File.join(FORMATTED_DIRECTORY, filename.to_s)
  cleaned_output_path = File.join(CLEANED_DIRECTORY, filename.to_s)

  first_line = first_values.join(DELIMITER)
  second_line = second_values.join(DELIMITER)

  File.open(output_csv_path, "w") do |file|
    file.puts first_line
    file.puts second_line
  end

  FileUtils.cp(cleaned_file_path, cleaned_output_path)

  puts "CSV has been outputted to #{output_csv_path} and cleaned file has been copied to #{cleaned_output_path}"
end
