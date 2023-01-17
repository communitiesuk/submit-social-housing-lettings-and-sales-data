class Form::Sales::Pages::Buyer1EthnicBackgroundWhite < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_ethnic_background_white"
    @depends_on = [{
      "ethnic_group" => 0,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer1EthnicBackgroundWhite.new(nil, nil, self),
    ]
  end
end
