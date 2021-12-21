class FormHandler
  include Singleton
  attr_reader :forms

  def initialize
    @forms = get_all_forms
  end

  def get_form(form)
    @forms[form] ||= Form.new(form)
  end

private

  def get_all_forms
    forms = {}
    directories.each do |directory|
      Dir.glob("#{directory}/*.json").each do |form_path|
        form_name = form_path.sub(".json", "").split("/")[-1]
        forms[form_name] = Form.new(form_path, form_name)
      end
    end
    forms
  end

  def directories
    Rails.env.test? ? ["spec/fixtures/forms"] : ["config/forms"]
  end
end
