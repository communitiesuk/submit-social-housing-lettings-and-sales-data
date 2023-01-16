class Form::Sales::Pages::ExtraBorrowing < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [{
                     "mortgageused" => 1,
                   }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::ExtraBorrowing.new(nil, nil, self),
    ]
  end
end
