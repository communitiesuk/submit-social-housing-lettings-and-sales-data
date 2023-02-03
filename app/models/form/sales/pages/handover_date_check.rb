class Form::Sales::Pages::HandoverDateCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "handover_date_check"
    @depends_on = [{ "saledate_check" => nil, "hodate_3_years_or_more_saledate?" => true },
                   { "saledate_check" => 1, "hodate_3_years_or_more_saledate?" => true }]
    @informative_text = {}
    @title_text = {
      "translation" => "validations.sale_information.hodate.must_be_less_than_3_years_from_saledate",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::HandoverDateCheck.new(nil, nil, self),
    ]
  end
end
