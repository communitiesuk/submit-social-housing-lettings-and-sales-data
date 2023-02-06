class Form::Lettings::Questions::PschargeBiWeekly < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "pscharge"
    @check_answer_label = "Personal service charge"
    @header = "What is the personal service charge?"
    @type = "numeric"
    @width = 5
    @check_answers_card_number = 0
    @min = 0
    @hint_text = "For example, for heating or hot water. This doesn’t include housing benefit or Universal Credit."
    @step = 0.01
    @fields_to_add = %w[brent scharge pscharge supcharg]
    @result_field = "tcharge"
    @hidden_in_check_answers = true
    @prefix = "£"
    @suffix = " every 2 weeks"
  end
end
