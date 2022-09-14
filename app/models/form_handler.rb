class FormHandler
  include Singleton
  attr_reader :forms

  def initialize
    @forms = get_all_forms
  end

  def get_form(form)
    @forms[form].present? ? @forms[form]["form"] : nil
  end

  def current_lettings_form
    forms["current_lettings"]["form"]
  end

  def current_sales_form
    forms["current_sales"]["form"]
  end

  def sales_forms
    sales_sections = [] # Add section classes here e.g. Form::Sales::Property::Sections::PropertyInformation
    current_form = Form.new(nil, "#{current_collection_start_year}_#{current_collection_start_year + 1}_sales", sales_sections, "sales")
    previous_form = Form.new(nil, "#{current_collection_start_year - 1}_#{current_collection_start_year}_sales", sales_sections, "sales")
    { "2022_2023_sales" => { "form" => Form.new(nil, "2022_2023_sales", sales_sections, "sales"), "type" => "sales" },
      "current_sales" => { "form" => current_form, "type" => "sales", "start_year" => current_form.start_date.year },
      "previous_sales" => { "form" => previous_form, "type" => "sales", "start_year" => previous_form.start_date.year } }
  end

  def lettings_forms
    forms = {}
    directories.each do |directory|
      Dir.glob("#{directory}/*.json").each do |form_path|
        form_name = File.basename(form_path, ".json")
        form = Form.new(form_path, form_name)
        forms[form_name] = { "form" => form, "type" => "lettings", "start_year" => form.start_date.year }
        if form.start_date.year + 1 == current_collection_start_year && forms["previous_lettings"].blank?
          forms["previous_lettings"] = { "form" => form, "type" => "lettings", "start_year" => form.start_date.year }
        elsif form.start_date.year == current_collection_start_year && forms["current_lettings"].blank?
          forms["current_lettings"] = { "form" => form, "type" => "lettings", "start_year" => form.start_date.year }
        elsif form.start_date.year - 1 == current_collection_start_year && forms["next_lettings"].blank?
          forms["next_lettings"] = { "form" => form, "type" => "lettings", "start_year" => form.start_date.year }
        end
      end
    end
    forms
  end

private

  def current_collection_start_year
    today = Time.zone.now
    window_end_date = Time.zone.local(today.year, 4, 1)
    today < window_end_date ? today.year - 1 : today.year
  end

  def get_all_forms
    lettings_forms.merge(sales_forms)
  end

  def directories
    Rails.env.test? ? ["spec/fixtures/forms"] : ["config/forms"]
  end
end
