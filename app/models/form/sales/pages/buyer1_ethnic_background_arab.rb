class Form::Sales::Pages::Buyer1EthnicBackgroundArab < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_ethnic_background_arab"
    @depends_on = [{
      "ethnic_group" => 4,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer1EthnicBackgroundArab.new(nil, nil, self),
    ]
  end
end
