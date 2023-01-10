class Form::Sales::Pages::Age2 < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_age"
    @depends_on = [{
      "jointpur" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2AgeKnown.new(nil, nil, self),
      Form::Sales::Questions::Age2.new(nil, nil, self),
    ]
  end
end
