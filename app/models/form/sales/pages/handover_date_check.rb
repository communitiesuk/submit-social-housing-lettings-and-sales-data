class Form::Sales::Pages::HandoverDateCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "handover_date_check"
    @copy_key = "sales.soft_validations.hodate_check"
    @informative_text = {}
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [],
    }
  end

  def depends_on
    if form.start_year_2025_or_later?
      [{ "saledate_check" => nil, "hodate_5_years_or_more_saledate?" => true },
       { "saledate_check" => 1, "hodate_5_years_or_more_saledate?" => true }]
    else
      [{ "saledate_check" => nil, "hodate_3_years_or_more_saledate?" => true },
       { "saledate_check" => 1, "hodate_3_years_or_more_saledate?" => true }]
    end
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::HandoverDateCheck.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    %w[hodate saledate]
  end
end
