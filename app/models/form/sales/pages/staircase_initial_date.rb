class Form::Sales::Pages::StaircaseInitialDate < ::Form::Page
  def initialize(id, hsh, subsection)
    super(id, hsh, subsection)
    @id = "staircase_initial_date"
    @header = ""
    @depends_on = [{
      "is_firststair?" => true,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::StaircaseInitialDate.new(nil, nil, self),
    ]
  end
end
