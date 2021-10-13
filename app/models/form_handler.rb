class FormHandler
  include Singleton

  def initialize
    @forms = {}
  end

  def get_form(form)
    # binding.pry
    @forms[form] ||= Form.new(form)
  end

  def get_all_forms
    Dir.foreach("config/forms") do |filename|
      next if (filename == ".") || (filename == "..")

      form_name = filename.sub(".json", "")
      @forms[form_name] = Form.new(form_name)
    end
    @forms
  end
end
