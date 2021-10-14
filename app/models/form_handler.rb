class FormHandler
  include Singleton
  attr_reader :forms

  def initialize
    @forms = get_all_forms
  end

  def get_form(form)
    return @forms["test_form"] ||= Form.new("test_form") if ENV["RAILS_ENV"] == "test"

    @forms[form] ||= Form.new(form)
  end


  private
  def get_all_forms
    forms = {}
    directories = ["config/forms", "spec/fixtures/forms"]
    directories.each do |directory|
      Dir.glob("#{directory}/*.json").each do |form_path|
        form_name = form_path.sub(".json", "").split("/")[-1]
        forms[form_name] = Form.new(form_path)
      end
    end
    forms
  end
end
