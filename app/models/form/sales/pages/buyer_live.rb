class Form::Sales::Pages::BuyerLive < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_live"
  end

  def depends_on
    [{ "companybuy" => 2 }] unless form.start_year_2025_or_later?
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::BuyerLive.new(nil, nil, self),
    ]
  end
end
