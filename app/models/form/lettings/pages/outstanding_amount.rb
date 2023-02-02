class Form::Lettings::Pages::OutstandingAmount < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "outstanding_amount"
    @depends_on = [{ "hb" => 1, "hbrentshortfall" => 1 }, { "hb" => 6, "hbrentshortfall" => 1 }]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::TshortfallKnown.new(nil, nil, self),
      Form::Lettings::Questions::Tshortfall.new(nil, nil, self),
    ]
  end
end
