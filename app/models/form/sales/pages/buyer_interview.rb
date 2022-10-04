class Form::Sales::Pages::BuyerInterview < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_interview"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::BuyerInterview.new(nil, nil, self),
    ]
  end
end
