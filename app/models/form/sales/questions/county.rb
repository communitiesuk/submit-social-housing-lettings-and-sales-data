class Form::Sales::Questions::County < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "county"
    @header = "County (optional)"
    @type = "text"
    @plain_label = true
    @check_answer_label = "County"
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
    @question_number = 15
    @hide_question_number_on_page = true
  end
end
