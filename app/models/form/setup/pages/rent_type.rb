class Form::Setup::Pages::RentType < ::Form::Page
  def initialize(_id, hsh, subsection)
    super("rent_type", hsh, subsection)
    @header = ""
    @description = ""
    @questions = questions
    @depends_on = [{ "supported_housing_schemes_enabled?" => true }]
    @derived = true
  end

  def questions
    [
      Form::Setup::Questions::RentType.new(nil, nil, self),
      Form::Setup::Questions::IrproductOther.new(nil, nil, self),
    ]
  end
end
