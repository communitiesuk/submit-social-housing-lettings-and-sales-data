class Form::Sales::Questions::NumberOfOthersInProperty < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hholdcount"
    @check_answer_label = "Number of other people living in the property"
    @header = "Q35 - Besides the buyer(s), how many other people live or will live in the property?"
    @type = "numeric"
    @hint_text = "You can provide details for a maximum of 4 other people."
    @width = 2
    @min = 0
    @max = 4
  end
end
