class Form::Sales::Pages::AboutPrice < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "about_price"
    @header = "About the price of the property"
    @description = ""
    @subsection = subsection
    @depends_on = [{
      "soctenant" => 2,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Value.new(nil, nil, self),
    ]
  end
end
