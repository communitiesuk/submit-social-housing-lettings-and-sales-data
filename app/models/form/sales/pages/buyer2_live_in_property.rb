class Form::Sales::Pages::Buyer2LiveInProperty < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_live_in_property"
    @depends_on = [{
      "jointpur" => 1,
      "privacynotice" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2LiveInProperty.new(nil, nil, self),
    ]
  end
end
