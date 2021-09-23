class Form
  attr_reader :form_definition

  def initialize(start_year, end_year)
    form_json = "config/forms/#{start_year}_#{end_year}.json"
    raise "No form definition file exists for given year".freeze unless File.exist?(form_json)

    @form_definition = JSON.parse(File.open(form_json).read)
  end

  # Returns a hash with sections as keys
  def all_sections
    @all_sections ||= @form_definition["sections"]
  end

  # Returns a hash with subsections as keys
  def all_subsections
    @all_subsections ||= all_sections.map { |_section_key, section_value|
      section_value["subsections"]
    }.reduce(:merge)
  end

  # Returns a hash with pages as keys
  def all_pages
    @all_pages ||= all_subsections.map { |_subsection_key, subsection_value|
      subsection_value["pages"]
    }.reduce(:merge)
  end

  # Returns a hash with the pages as keys
  def pages_for_subsection(subsection)
    all_subsections[subsection]["pages"]
  end

  # Returns a hash with the questions as keys
  def questions_for_page(page)
    all_pages[page]["questions"]
  end

  def first_page_for_subsection(subsection)
    pages_for_subsection(subsection).keys.first
  end

  def subsection_for_page(page)
    all_subsections.find { |_subsection_key, subsection_value|
      subsection_value["pages"].key?(page)
    }.first
  end

  def next_page(previous_page)
    subsection = subsection_for_page(previous_page)
    previous_page_idx = pages_for_subsection(subsection).keys.index(previous_page)
    pages_for_subsection(subsection).keys[previous_page_idx + 1] || previous_page # Placeholder until we have a check answers page
  end

  def previous_page(current_page)
    subsection = subsection_for_page(current_page)
    current_page_idx = pages_for_subsection(subsection).keys.index(current_page)
    return unless current_page_idx.positive?

    pages_for_subsection(subsection).keys[current_page_idx - 1]
  end
end
