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

private

  def get_all_forms
    forms = {}
    directories.each do |directory|
      Dir.glob("#{directory}/*.json").each do |form_path|
        form_name = File.basename(form_path, ".json")
        forms[form_name] = Form.new(form_path, form_name, setup_path)
      end
    end
    forms
  end

  def setup_path
    return "spec/fixtures/forms/setup/log_setup.json" if Rails.env.test?

    "config/forms/setup/log_setup.json"
  end

  def directories
    Rails.env.test? ? ["spec/fixtures/forms"] : ["config/forms"]
  end
end
