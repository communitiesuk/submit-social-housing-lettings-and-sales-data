class Form::Setup::Pages::RentType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "rent_type"
    @header = ""
    @description = ""
    @questions = questions
    @depends_on = [{ "supported_housing_schemes_enabled?" => true }]
    @derived = true
    @subsection = subsection
  end

  def questions
    [
      Form::Setup::Questions::RentType.new(nil, nil, self),
      Form::Setup::Questions::IrproductOther.new(nil, nil, self),
    ]
  end
end
