class Form::Setup::Questions::TenancyStartDate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "startdate"
    @check_answer_label = "Tenancy start date"
    @header = "What is the tenancy start date?"
    @type = "date"
    @page = page
  end
end
