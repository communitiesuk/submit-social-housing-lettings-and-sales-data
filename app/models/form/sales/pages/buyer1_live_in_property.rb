class Form::Sales::Pages::Buyer1LiveInProperty < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_live_in_property"
    @depends_on = [{
      "privacynotice" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer1LiveInProperty.new(nil, nil, self),
    ]
  end
end
