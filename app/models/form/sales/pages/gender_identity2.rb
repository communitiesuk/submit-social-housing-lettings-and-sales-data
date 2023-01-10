class Form::Sales::Pages::GenderIdentity2 < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_gender_identity"
    @depends_on = [{
      "jointpur" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::GenderIdentity2.new(nil, nil, self),
    ]
  end
end
