class FormHandler
  include Singleton

  def initialize
    @forms = {}
    get_all_forms
  end

  def get_form(form)
    # binding.pry
    @forms[form] ||= Form.new(form)
  end

  def get_all_forms
    directories = ["config/forms", "spec/fixtures/forms"]
    directories.each do |directory|
      Dir.foreach(directory) do |filename|
        next if (filename == ".") || (filename == "..")

        form_name = filename.sub(".json", "")
        form_path = "#{directory}/#{filename}"
        @forms[form_name] = Form.new(form_path)
      end
    end
    @forms
  end
end
