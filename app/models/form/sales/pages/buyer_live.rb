class Form::Sales::Pages::BuyerLive < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_live"
    @copy_key = "sales.setup.buylivein"
    @depends_on = [{
      "companybuy" => 2,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::BuyerLive.new(nil, nil, self),
    ]
  end
end
