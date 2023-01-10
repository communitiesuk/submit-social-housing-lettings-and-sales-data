class Form::Sales::Pages::GenderIdentity1 < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_gender_identity"
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::GenderIdentity1.new(nil, nil, self),
    ]
  end
end
