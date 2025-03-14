class Form::Sales::Pages::Buyer1EthnicBackgroundMixed < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_ethnic_background_mixed"
    @copy_key = "sales.household_characteristics.ethnic.ethnic_background_mixed"
    @depends_on = [{
      "ethnic_group" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer1EthnicBackgroundMixed.new(nil, nil, self),
    ]
  end
end
