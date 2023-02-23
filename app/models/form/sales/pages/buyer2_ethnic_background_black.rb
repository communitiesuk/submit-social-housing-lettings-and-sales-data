class Form::Sales::Pages::Buyer2EthnicBackgroundBlack < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_ethnic_background_black"
    @depends_on = [{
      "ethnic_group2" => 3,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2EthnicBackgroundBlack.new(nil, nil, self),
    ]
  end
end
