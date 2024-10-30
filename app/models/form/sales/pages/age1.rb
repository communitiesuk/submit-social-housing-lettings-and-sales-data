class Form::Sales::Pages::Age1 < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_age"
    @copy_key = "sales.household_characteristics.age1"
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
      Form::Sales::Questions::Buyer1AgeKnown.new(nil, nil, self),
      Form::Sales::Questions::Age1.new(nil, nil, self),
    ]
  end
end
