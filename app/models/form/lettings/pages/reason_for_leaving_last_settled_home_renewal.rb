class Form::Lettings::Pages::ReasonForLeavingLastSettledHomeRenewal < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "reason_for_leaving_last_settled_home_renewal"
    @header = ""
    @depends_on = [{ "renewal" => 1 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Reason.new(nil, nil, self)]
  end
end
