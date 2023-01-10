class Form::Sales::Pages::Buyer1EthnicGroup < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_ethnic_group"
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer1EthnicGroup.new(nil, nil, self),
    ]
  end
end
