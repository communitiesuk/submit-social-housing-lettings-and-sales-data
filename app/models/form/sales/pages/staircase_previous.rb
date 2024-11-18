class Form::Sales::Pages::StaircasePrevious < ::Form::Page
  def initialize(id, hsh, subsection)
    super(id, hsh, subsection)
    @id = "staircase_previous"
    @copy_key = "sales.sale_information.stairprevious"
    @depends_on = [{
      "is_firststair?" => false,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::StaircaseCount.new(nil, nil, self),
      Form::Sales::Questions::StaircaseLastDate.new(nil, nil, self),
      Form::Sales::Questions::StaircaseInitialDate.new(nil, nil, self),
    ].compact
  end
end
