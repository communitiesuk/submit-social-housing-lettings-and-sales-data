class Form::Sales::Pages::Buyer1EthnicGroup < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_ethnic_group"
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
      Form::Sales::Questions::Buyer1EthnicGroup.new(nil, nil, self),
    ]
  end
end
