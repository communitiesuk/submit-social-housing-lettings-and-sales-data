class Form::Sales::Pages::StaircaseFirstTime < ::Form::Page
  def initialize(id, hsh, subsection)
    super(id, hsh, subsection)
    @id = "staircase_first_time"
    @depends_on = [{
      "staircase" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::StaircaseFirstTime.new(nil, nil, self),
    ]
  end
end
