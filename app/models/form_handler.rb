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
      Dir.foreach(directory) do |filename|
        next if (filename == ".") || (filename == "..")

        form_name = filename.sub(".json", "")
        form_path = "#{directory}/#{filename}"
        forms[form_name] = Form.new(form_path)
      end
    end
    forms
  end
end
