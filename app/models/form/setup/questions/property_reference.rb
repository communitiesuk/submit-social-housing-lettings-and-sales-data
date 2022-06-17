class Form::Setup::Questions::PropertyReference < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "propcode"
    @check_answer_label = "Property reference"
    @header = "What is the property reference?"
    @hint_text = "This is how you usually refer to this property on your own systems."
    @type = "text"
    @width = 10
    @page = page
  end
end
