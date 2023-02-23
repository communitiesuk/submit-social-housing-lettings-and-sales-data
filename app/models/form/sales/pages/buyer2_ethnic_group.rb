class Form::Sales::Pages::Buyer2EthnicGroup < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_ethnic_group"
    @depends_on = [
      {
        "jointpur" => 1,
        "privacynotice" => 1,
      },
      {
        "jointpur" => 1,
        "noint" => 1,
      },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2EthnicGroup.new(nil, nil, self),
    ]
  end
end
