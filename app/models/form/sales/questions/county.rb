class Form::Sales::Questions::County < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "county"
    @header = "County (optional)"
    @type = "text"
    @plain_label = true
    @check_answer_label = "Q15 - County"
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end
end
