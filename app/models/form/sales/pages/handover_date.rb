class Form::Sales::Pages::HandoverDate < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "handover_date"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [{
      "ownershipsch" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::HandoverDate.new(nil, nil, self),
    ]
  end
end
