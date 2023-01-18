class Form::Sales::Questions::OtherOwnershipType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "othtype"
    @check_answer_label = "Type of other sale"
    @header = "What type of sale is it?"
    @type = "text"
    @width = 10
  end
end
