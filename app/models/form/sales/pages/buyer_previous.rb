class Form::Sales::Pages::BuyerPrevious < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_previous"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::BuyerPrevious.new(nil, nil, self),
    ]
  end
end
