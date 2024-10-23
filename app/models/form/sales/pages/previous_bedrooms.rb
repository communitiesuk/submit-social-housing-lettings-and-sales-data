class Form::Sales::Pages::PreviousBedrooms < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "previous_bedrooms"
    @copy_key = "sales.sale_information.frombeds"
    @depends_on = [
      {
        "soctenant" => 1,
      },
      {
        "soctenant" => 0,
      },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PreviousBedrooms.new(nil, nil, self),
    ]
  end
end
