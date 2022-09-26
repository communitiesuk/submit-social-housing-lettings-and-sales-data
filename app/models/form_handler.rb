class FormHandler
  include Singleton
  attr_reader :forms

  def initialize
    @forms = get_all_forms
  end

  def get_form(form)
    @forms[form]
  end

  def current_lettings_form
    forms["current_lettings"]
  end

  def current_sales_form
    forms["current_sales"]
  end

  def sales_forms
    sales_sections = [
      Form::Sales::Property::Sections::PropertyInformation,
      Form::Sales::Sections::Household,
    ]
    current_form = Form.new(nil, current_collection_start_year, sales_sections, "sales")
    previous_form = Form.new(nil, current_collection_start_year - 1, sales_sections, "sales")
    { "current_sales" => current_form,
      "previous_sales" => previous_form }
  end

  def lettings_forms
    forms = {}
    directories.each do |directory|
      Dir.glob("#{directory}/*.json").each do |form_path|
        form = Form.new(form_path)

        form_to_set = form_name_from_start_year(form.start_date.year, "lettings")
        forms[form_to_set] = form if forms[form_to_set].blank?
      end
    end
    forms
  end

  def current_collection_start_year
    today = Time.zone.now
    window_end_date = Time.zone.local(today.year, 4, 1)
    today < window_end_date ? today.year - 1 : today.year
  end

  def form_name_from_start_year(year, type)
    form_mappings = { 0 => "current_#{type}", 1 => "previous_#{type}", -1 => "next_#{type}" }
    form_mappings[current_collection_start_year - year]
  end

private

  def get_all_forms
    lettings_forms.merge(sales_forms)
  end

  def directories
    Rails.env.test? ? ["spec/fixtures/forms"] : ["config/forms"]
  end
end
