class Form::Sales::Questions::PostcodeFull < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "postcode_full"
    @check_answer_label = "Property full postcode!!!"
    @header = "The Full Postcode outer inner"
    @type = "text"
    @page = page
    @width = 10
  end
end
