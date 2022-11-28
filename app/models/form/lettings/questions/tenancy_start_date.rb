class Form::Lettings::Questions::TenancyStartDate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "startdate"
    @check_answer_label = "Tenancy start date"
    @header = "What is the tenancy start date?"
    @type = "date"
    @unresolved_hint_text = "Check the tenancy start date is correct"
    @page = page
  end
end
