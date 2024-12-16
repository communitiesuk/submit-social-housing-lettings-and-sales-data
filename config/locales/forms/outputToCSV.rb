require "yaml"
require "csv"
require "fileutils"

# Define variables
type = "lettings" # or "sales"
years = [2023, 2024, 2025]
sections = %w[household_characteristics household_situation income_benefits_and_savings other_household_information property_information setup sale_information property_information] # or sales section ids

# Define the output file path
output_file = "config/locales/forms/output.csv"

# Open a CSV file for writing
CSV.open(output_file, "w") do |csv|
  # Write the headers
  csv << ["Year", "Type", "Section", "Parent Key", "Question ID", "Page Header", "Check Answer Label", "Check Answer Prompt", "Hint Text", "Question Text"]

  # Recursive method to process nested questions
  def process_questions(year, type, section_name, parent_key, properties, csv)
    properties.each do |key, value|
      if value.is_a?(Hash) && value.key?("question_text")
        csv << [
          year,
          type,
          section_name,
          parent_key,
          key,
          properties["page_header"],
          value["check_answer_label"],
          value["check_answer_prompt"],
          value["hint_text"],
          value["question_text"],
        ]
      elsif value.is_a?(Hash)
        process_questions(year, type, section_name, key, value, csv)
      end
    end
  end

  # Iterate over each year
  years.each do |year|
    # Iterate over each section
    sections.each do |section_name|
      # Define the YAML file path
      yaml_file = "config/locales/forms/#{year}/#{type}/#{section_name}.en.yml"

      # Check if the YAML file exists
      if File.exist?(yaml_file)
        # Load the YAML file
        yaml_content = YAML.load_file(yaml_file)

        # Check if the key path exists
        if yaml_content.dig("en", "forms", year, type, section_name)
          # Process the questions data
          yaml_content["en"]["forms"][year][type][section_name].each do |parent_key, properties|
            if properties.is_a?(Hash) && properties.key?("question_text")
              csv << [
                year,
                type,
                section_name,
                parent_key,
                parent_key,
                properties["page_header"],
                properties["check_answer_label"],
                properties["check_answer_prompt"],
                properties["hint_text"],
                properties["question_text"],
              ]
            else
              process_questions(year, type, section_name, parent_key, properties, csv)
            end
          end
        else
          puts "The specified key path does not exist in the YAML file for section: #{section_name} in year: #{year}."
        end
      else
        puts "The YAML file does not exist: #{yaml_file}"
      end
    end
  end
end

puts "CSV file created successfully at #{output_file}"
