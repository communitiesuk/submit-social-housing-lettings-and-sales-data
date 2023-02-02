class Form::Lettings::Pages::ReasonForLeavingLastSettledHome < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "reason_for_leaving_last_settled_home"
    @depends_on = [{ "renewal" => 0 }]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::Reason.new(nil, nil, self),
      Form::Lettings::Questions::Reasonother.new(nil, nil, self),
    ]
  end
end
