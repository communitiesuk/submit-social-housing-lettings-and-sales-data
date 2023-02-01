class Form::Lettings::Pages::IncomeAmount < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "income_amount"
    @header = "Total household income"
    @depends_on = [{ "net_income_known" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Earnings.new(nil, nil, self), Form::Lettings::Questions::Incfreq.new(nil, nil, self)]
  end
end
