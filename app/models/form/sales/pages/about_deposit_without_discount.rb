class Form::Sales::Pages::AboutDepositWithoutDiscount < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @header = "About the deposit"
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "type" => 2 },
      { "type" => 24 },
      { "type" => 16 },
      { "type" => 28 },
      { "type" => 31 },
      { "type" => 30 },
      { "type" => 8 },
      { "type" => 14 },
      { "type" => 27 },
      { "type" => 9 },
      { "type" => 29 },
      { "type" => 21 },
      { "type" => 22 },
      { "type" => 10 },
      { "type" => 12 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::DepositAmount.new(nil, nil, self),
    ]
  end
end
