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
    current_form = Form.new(nil, current_collection_start_year, sales_sections, "sales")
    previous_form = Form.new(nil, current_collection_start_year - 1, sales_sections, "sales")
    { "current_sales" => { "form" => current_form, "type" => "sales", "start_year" => current_form.start_date.year },
      "previous_sales" => { "form" => previous_form, "type" => "sales", "start_year" => previous_form.start_date.year } }
  end

  def lettings_forms
    forms = {}
    directories.each do |directory|
      Dir.glob("#{directory}/*.json").each do |form_path|
        form = Form.new(form_path)
        lettings_form_definition = { "form" => form, "type" => "lettings", "start_year" => form.start_date.year }

        form_mappings = { 0 => "current_lettings", 1 => "previous_lettings", -1 => "next_lettings" }
        form_to_set = form_mappings[current_collection_start_year - form.start_date.year]
        forms[form_to_set] = lettings_form_definition if forms[form_to_set].blank?
      end
    end
    forms
  end

  def current_collection_start_year
    today = Time.zone.now
    window_end_date = Time.zone.local(today.year, 4, 1)
    today < window_end_date ? today.year - 1 : today.year
  end

private

  def get_all_forms
    lettings_forms.merge(sales_forms)
  end

  def directories
    Rails.env.test? ? ["spec/fixtures/forms"] : ["config/forms"]
  end
end
