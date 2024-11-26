class Form::Sales::Pages::Grant < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "grant"
    @depends_on = [{
      "right_to_buy?" => false,
      "rent_to_buy_full_ownership?" => false,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Grant.new(nil, nil, self),
    ]
  end
end
