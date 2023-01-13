class Form::Sales::Pages::HandoverDate < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "handover_date"
    @depends_on = [
      { "ownershipsch" => 1, "resale" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::HandoverDate.new(nil, nil, self),
    ]
  end
end
