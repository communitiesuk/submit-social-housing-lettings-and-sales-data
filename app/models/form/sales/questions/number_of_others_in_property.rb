class Form::Sales::Questions::NumberOfOthersInProperty < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hholdcount"
    @check_answer_label = "Number of other people living in the property"
    @header = "Besides the buyers, how many other people live in the property?"
    @type = "numeric"
    @hint_text = "You can provide details for a maximum of 4 other people."
    @page = page
    @width = 2
    end
end
