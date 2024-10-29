class Form::Sales::Pages::Buyer1EthnicBackgroundBlack < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_ethnic_background_black"
    @copy_key = "sales.household_characteristics.ethnic.ethnic_background_black"
    @depends_on = [{
      "ethnic_group" => 3,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer1EthnicBackgroundBlack.new(nil, nil, self),
    ]
  end
end
