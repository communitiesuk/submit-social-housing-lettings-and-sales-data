class Form::Sales::Pages::Buyer2EthnicBackgroundMixed < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_ethnic_background_mixed"
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
