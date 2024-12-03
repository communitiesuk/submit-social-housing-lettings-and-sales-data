class Form::Sales::Pages::MonthlyRentStaircasing < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "monthly_rent_staircasing"
    @copy_key = "sales.sale_information.mrent_staircasing"
    @depends_on = [{
      "stairowned_100?" => false,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MonthlyRentBeforeStaircasing.new(nil, nil, self),
      Form::Sales::Questions::MonthlyRentAfterStaircasing.new(nil, nil, self),
    ]
  end
end
