class Form::Lettings::Questions::Offered < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "offered"
    @check_answer_label = "Times previously offered since becoming available"
    @header = "Since becoming available, how many times has the property been previously offered?"
    @type = "numeric"
    @width = 2
    @check_answers_card_number = 0
    @max = 150
    @min = 0
    @hint_text = "If the property is being offered for let for the first time, enter 0."
    @step = 1
  end
end
