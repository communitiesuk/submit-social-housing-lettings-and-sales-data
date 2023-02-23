class Form::Sales::Pages::Buyer2EthnicBackgroundWhite < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_ethnic_background_white"
    @depends_on = [{
      "ethnic_group2" => 0,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2EthnicBackgroundWhite.new(nil, nil, self),
    ]
  end
end
