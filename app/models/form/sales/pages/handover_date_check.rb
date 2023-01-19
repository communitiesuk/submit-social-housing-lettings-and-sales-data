class Form::Sales::Pages::HandoverDateCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [{ "hodate_3_years_or_more_saledate?" => true }]
    @informative_text = {}
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::HandoverDateCheck.new(nil, nil, self),
    ]
  end
end
