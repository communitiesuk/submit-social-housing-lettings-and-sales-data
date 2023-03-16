class Form::Lettings::Questions::TenancyLength < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "tenancylength"
    @check_answer_label = "Length of fixed-term tenancy"
    @header = "What is the length of the fixed-term tenancy to the nearest year?"
    @type = "numeric"
    @width = 2
    @check_answers_card_number = 0
    @max = 150
    @min = 0
    @hint_text = "Don’t include the starter or introductory period."
    @step = 1
    @question_number = 28
  end
end
