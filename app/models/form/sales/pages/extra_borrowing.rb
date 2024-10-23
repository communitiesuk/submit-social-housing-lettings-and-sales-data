class Form::Sales::Pages::ExtraBorrowing < ::Form::Page
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @ownershipsch = ownershipsch
    @copy_key = "sales.sale_information.extrabor"
    @description = ""
    @subsection = subsection
    @depends_on = [{
      "mortgageused" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::ExtraBorrowing.new(nil, nil, self, ownershipsch: @ownershipsch),
    ]
  end
end
