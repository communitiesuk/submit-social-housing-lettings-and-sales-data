class Form::Sales::Setup::Pages::PurchaserCode < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "purchaser_code"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Setup::Questions::PurchaserCode.new(nil, nil, self),
    ]
  end
end
