class FormHandler
  include Singleton
  attr_reader :forms

  def initialize
    @forms = get_all_forms
  end

  def get_form(form)
    @forms[form]
  end

  def current_form
    forms[forms.keys.max_by(&:to_i)]
  end

  def sales_forms
    sales_sections = [] # Add section classes here e.g. Form::Sales::Property::Sections::PropertyInformation
    { "2022_2023_sales" => Form.new(nil, "2022_2023_sales", sales_sections, "sales") }
  end

  def lettings_forms
    forms = {}
    directories.each do |directory|
      Dir.glob("#{directory}/*.json").each do |form_path|
        form_name = File.basename(form_path, ".json")
        form = Form.new(form_path, form_name)
        forms[form_name] = form
        if form.start_date.year + 1 == current_collection_start_year && forms["previous_lettings"].blank?
          forms["previous_lettings"] = form
        elsif form.start_date.year == current_collection_start_year && forms["current_lettings"].blank?
          forms["current_lettings"] = form
        elsif form.start_date.year - 1 == current_collection_start_year && forms["next_lettings"].blank?
          forms["next_lettings"] = form
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
