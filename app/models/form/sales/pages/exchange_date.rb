class Form::Sales::Pages::ExchangeDate < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "exchange_contracts"
    @copy_key = "sales.sale_information.exchange_date"
    @depends_on = [{
      "resale" => 2,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::ExchangeDate.new(nil, nil, self),
    ]
  end
end
