class Form::Sales::Pages::MonthlyRentStaircasingOwned < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "monthly_rent_staircasing_owned"
    @copy_key = "sales.sale_information.mrent_staircasing"
    @header = ""
    @depends_on = [{
      "stairowned_100?" => true,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MonthlyRentBeforeStaircasing.new(nil, nil, self),
    ]
  end
end
