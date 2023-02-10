class Form::Sales::Pages::Buyer2EthnicBackgroundArab < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_ethnic_background_arab"
    @depends_on = [{
      "ethnic_group2" => 4,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2EthnicBackgroundArab.new(nil, nil, self),
    ]
  end
end
