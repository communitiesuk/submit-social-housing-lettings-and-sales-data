class Form::Sales::Pages::BuyerStillServing < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_still_serving"
    @header = ""
    @subsection = subsection
    @depends_on = [{
      "hhregres" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::BuyerStillServing.new(nil, nil, self),
    ]
  end
end
