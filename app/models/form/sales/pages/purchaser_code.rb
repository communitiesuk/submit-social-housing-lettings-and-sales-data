class Form::Sales::Pages::PurchaserCode < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "purchaser_code"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PurchaserCode.new(nil, nil, self),
    ]
  end
end
