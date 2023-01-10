class Form::Lettings::Questions::TenancyStartDate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "startdate"
    @check_answer_label = "Tenancy start date"
    @header = "What is the tenancy start date?"
    @type = "date"
    @unresolved_hint_text = "Some scheme details have changed, and now this log needs updating. Check that the tenancy start date is correct."
  end
end
