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
    sales_sections = [Form::Sales::Setup::Sections::Setup]
    { "2022_2023_sales" => Form.new(nil, "2022_2023_sales", sales_sections, "sales") }
  end

  def lettings_forms
    forms = {}
    directories.each do |directory|
      Dir.glob("#{directory}/*.json").each do |form_path|
        form_name = File.basename(form_path, ".json")
        forms[form_name] = Form.new(form_path, form_name)
      end
    end
    forms
  end

private

  def get_all_forms
    lettings_forms.merge(sales_forms)
  end

  def directories
    Rails.env.test? ? ["spec/fixtures/forms"] : ["config/forms"]
  end
end
