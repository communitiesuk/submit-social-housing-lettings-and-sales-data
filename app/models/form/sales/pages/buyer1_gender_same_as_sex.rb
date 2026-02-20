class Form::Sales::Pages::Buyer1GenderSameAsSex < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_gender_same_as_sex"
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
      Form::Sales::Questions::GenderSameAsSex1.new(nil, nil, self),
      Form::Sales::Questions::GenderDescription1.new(nil, nil, self),
    ]
  end
end
