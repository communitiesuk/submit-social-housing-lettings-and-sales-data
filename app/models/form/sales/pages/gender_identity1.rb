class Form::Sales::Pages::GenderIdentity1 < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_gender_identity"
    @depends_on = [
      {
        "buyer_has_seen_privacy_notice?" => true,
      },
      {
        "buyer_not_interviewed?" => true,
      },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::GenderIdentity1.new(nil, nil, self),
    ]
  end
end
