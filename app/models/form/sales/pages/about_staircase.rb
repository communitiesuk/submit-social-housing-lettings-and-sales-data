class Form::Sales::Pages::AboutStaircase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "about_staircasing"
    @header = "About the staircasing transaction"
    @depends_on = [{
      "staircase" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::StaircaseBought.new(nil, nil, self),
      Form::Sales::Questions::StaircaseOwned.new(nil, nil, self),
      Form::Sales::Questions::StaircaseSale.new(nil, nil, self),
    ]
  end
end
