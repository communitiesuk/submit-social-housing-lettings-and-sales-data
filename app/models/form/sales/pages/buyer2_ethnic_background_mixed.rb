class Form::Sales::Pages::Buyer2EthnicBackgroundMixed < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_ethnic_background_mixed"
    @copy_key = "sales.household_characteristics.ethnicbuy2.ethnic_background_black"
    @depends_on = [{
      "ethnic_group2" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2EthnicBackgroundMixed.new(nil, nil, self),
    ]
  end
end
