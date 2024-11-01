class Form::Lettings::Pages::IncomeAmount < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "income_amount"
    @copy_key = "lettings.income_and_benefits.income_amount"
    @depends_on = [{ "net_income_known" => 0 }]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::Incfreq.new(nil, nil, self),
      Form::Lettings::Questions::Earnings.new(nil, nil, self),
    ]
  end
end
