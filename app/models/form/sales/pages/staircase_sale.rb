class Form::Sales::Pages::StaircaseSale < ::Form::Page
  def initialize(id, hsh, subsection)
    super(id, hsh, subsection)
    @id = "staircase_sale"
    @copy_key = form.start_year_2025_or_later? ? "sales.sale_information.staircasesale" : "sales.sale_information.about_staircasing.staircasesale"
    @depends_on = [{
      "staircase" => 1,
      "stairowned" => 100,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::StaircaseSale.new(nil, nil, self)
    ].compact
  end
end
